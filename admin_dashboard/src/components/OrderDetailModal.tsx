import React, { useState, useRef } from 'react';
import { X, MapPin, Phone, MessageSquare, Volume2, Image as ImageIcon, Printer, CheckCircle2, Play, Pause, RotateCcw } from 'lucide-react';
import { IOrder } from '../types';
import { StatusBadge } from './StatusBadge';
import { AdminApiService } from '../services/api';

interface OrderDetailModalProps {
  order: IOrder | null;
  onClose: () => void;
  onStatusUpdated?: () => void;
}

const ALL_STATUSES = [
  'Placed',
  'Pickup Assigned',
  'Rider On the Way',
  'Pickup Completed',
  'Received at Store',
  'Inspection Started',
  'Cleaning Started',
  'Dry Cleaning Completed',
  'Ironing Started',
  'Quality Check',
  'Ready for Delivery',
  'Delivery Partner Assigned',
  'Out for Delivery',
  'Delivered',
  'Cancelled'
];

export const OrderDetailModal: React.FC<OrderDetailModalProps> = ({ order, onClose, onStatusUpdated }) => {
  if (!order) return null;

  const [currentStatus, setCurrentStatus] = useState(order.status || 'Placed');
  const [updating, setUpdating] = useState(false);
  const [activePhoto, setActivePhoto] = useState<string | null>(null);

  // Audio Player State
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);

  const cleanPhone = (order.customerPhone || '').replace(/\D/g, '');
  const formattedWhatsAppPhone = cleanPhone.length === 10 ? `91${cleanPhone}` : cleanPhone;
  const whatsappUrl = `https://wa.me/${formattedWhatsAppPhone}?text=${encodeURIComponent(`Hi ${order.customerName}, regarding your Dry Cleaning Order ${order.orderId}:`)}`;

  const resolveMediaUrl = (url?: string) => {
    if (!url) return '';
    if (url.startsWith('data:') || url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return `http://localhost:5000${url}`;
    return `http://localhost:5000/${url}`;
  };

  const handleStatusChange = async (newStatus: string) => {
    setUpdating(true);
    try {
      await AdminApiService.updateOrderStatus(order._id || order.id || order.orderId, newStatus);
      setCurrentStatus(newStatus);
      if (onStatusUpdated) onStatusUpdated();
    } catch (err) {
      console.error('Failed to update status:', err);
    } finally {
      setUpdating(false);
    }
  };

  const handlePrint = () => {
    window.print();
  };

  const togglePlayAudio = () => {
    if (!audioRef.current) return;
    if (isPlaying) {
      audioRef.current.pause();
    } else {
      audioRef.current.play().catch(err => console.error("Audio playback error:", err));
    }
  };

  const restartAudio = () => {
    if (!audioRef.current) return;
    audioRef.current.currentTime = 0;
    audioRef.current.play().catch(err => console.error("Audio playback error:", err));
  };

  const handleSeek = (e: React.ChangeEvent<HTMLInputElement>) => {
    const time = parseFloat(e.target.value);
    if (audioRef.current) {
      audioRef.current.currentTime = time;
      setCurrentTime(time);
    }
  };

  const formatTime = (secs: number) => {
    if (isNaN(secs) || secs < 0) return '0:00';
    const m = Math.floor(secs / 60);
    const s = Math.floor(secs % 60);
    return `${m}:${s < 10 ? '0' : ''}${s}`;
  };

  const resolvedVoiceUrl = resolveMediaUrl(order.voiceNoteUrl);

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        {/* Header */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--border-light)', paddingBottom: '16px', marginBottom: '20px' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <h2 className="heading-lg">{order.orderId}</h2>
              <StatusBadge status={currentStatus} />
            </div>
            <p className="text-muted" style={{ marginTop: 4 }}>Placed on: {new Date(order.createdAt).toLocaleString()}</p>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <button onClick={handlePrint} className="btn btn-outline" title="Print Tag / Receipt">
              <Printer size={16} /> Print
            </button>
            <button onClick={onClose} style={{ padding: 8, borderRadius: '50%', backgroundColor: 'var(--card-fill)' }}>
              <X size={20} color="var(--dark-navy)" />
            </button>
          </div>
        </div>

        {/* Quick Status Changer Dropdown */}
        <div style={{ backgroundColor: 'var(--primary-mint-light)', padding: '14px 18px', borderRadius: 'var(--radius-md)', marginBottom: '24px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--primary-mint-dark)', fontWeight: 700 }}>
            <CheckCircle2 size={20} />
            <span>Update Order Progress Stage:</span>
          </div>
          <select
            className="form-select"
            style={{ width: 'auto', fontWeight: 700, color: 'var(--dark-navy)', borderColor: 'var(--primary-mint)' }}
            value={currentStatus}
            disabled={updating}
            onChange={(e) => handleStatusChange(e.target.value)}
          >
            {ALL_STATUSES.map((st) => (
              <option key={st} value={st}>{st}</option>
            ))}
          </select>
        </div>

        {/* Customer Information & Actions */}
        <div className="card" style={{ marginBottom: '20px' }}>
          <h3 className="heading-md" style={{ marginBottom: '12px' }}>Customer & Pickup Details</h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', fontSize: '14px' }}>
            <div>
              <p style={{ color: 'var(--text-muted)', fontSize: '12px' }}>CUSTOMER NAME</p>
              <p style={{ fontWeight: 700, fontSize: '15px' }}>{order.customerName}</p>
            </div>
            <div>
              <p style={{ color: 'var(--text-muted)', fontSize: '12px' }}>PHONE NUMBER</p>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <span style={{ fontWeight: 700 }}>{order.customerPhone}</span>
                <a href={whatsappUrl} target="_blank" rel="noreferrer" className="btn btn-primary" style={{ padding: '4px 10px', fontSize: '12px' }}>
                  <MessageSquare size={14} /> WhatsApp
                </a>
              </div>
            </div>
            <div style={{ gridColumn: 'span 2' }}>
              <p style={{ color: 'var(--text-muted)', fontSize: '12px' }}>PICKUP & DELIVERY ADDRESS</p>
              <p style={{ fontWeight: 600 }}>{order.fullAddress} {order.landmark ? `(${order.landmark})` : ''}</p>
              {order.liveLocationUrl && (
                <a href={order.liveLocationUrl} target="_blank" rel="noreferrer" style={{ display: 'inline-flex', alignItems: 'center', gap: 6, color: 'var(--primary-mint-dark)', fontWeight: 700, marginTop: 6, fontSize: '13px' }}>
                  <MapPin size={16} /> Open Pin on Google Maps
                </a>
              )}
            </div>
            <div>
              <p style={{ color: 'var(--text-muted)', fontSize: '12px' }}>PICKUP SLOT</p>
              <p style={{ fontWeight: 600 }}>{order.pickupDate} ({order.pickupSlot})</p>
            </div>
            <div>
              <p style={{ color: 'var(--text-muted)', fontSize: '12px' }}>PAYMENT METHOD</p>
              <p style={{ fontWeight: 700, color: 'var(--dark-navy)' }}>{order.paymentMethod} {order.upiVpa ? `(${order.upiVpa})` : ''}</p>
            </div>
          </div>
        </div>

        {/* Special Instructions (Voice Note & Photos) */}
        {(order.hasVoiceInstruction || (order.photoUrls && order.photoUrls.length > 0) || order.notes) && (
          <div className="card" style={{ marginBottom: '20px', backgroundColor: '#fcfcfc' }}>
            <h3 className="heading-md" style={{ marginBottom: '12px' }}>Special Instructions & Attachments</h3>

            {order.notes && (
              <p style={{ marginBottom: 12, fontSize: '14px', fontStyle: 'italic', color: 'var(--dark-navy)', backgroundColor: '#fff', padding: '10px 14px', borderRadius: 6, border: '1px solid var(--border-light)' }}>
                "{order.notes}"
              </p>
            )}

            {/* Voice Instruction Interactive Audio Player */}
            {(order.hasVoiceInstruction || order.voiceNoteUrl) && resolvedVoiceUrl && (
              <div style={{ marginBottom: 16, padding: 14, background: '#ffffff', borderRadius: 8, border: '1.5px solid var(--primary-mint)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8, fontWeight: 700, fontSize: '13px', color: 'var(--dark-navy)' }}>
                  <Volume2 size={18} color="var(--primary-mint-dark)" /> Customer Voice Note Instruction:
                </div>

                <audio
                  ref={audioRef}
                  src={resolvedVoiceUrl}
                  preload="metadata"
                  onTimeUpdate={() => audioRef.current && setCurrentTime(audioRef.current.currentTime)}
                  onLoadedMetadata={() => audioRef.current && setDuration(audioRef.current.duration)}
                  onPlay={() => setIsPlaying(true)}
                  onPause={() => setIsPlaying(false)}
                  onEnded={() => setIsPlaying(false)}
                />

                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <button
                    onClick={togglePlayAudio}
                    style={{
                      width: 38,
                      height: 38,
                      borderRadius: '50%',
                      backgroundColor: 'var(--primary-mint)',
                      border: 'none',
                      color: '#ffffff',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      cursor: 'pointer',
                    }}
                    title={isPlaying ? 'Pause' : 'Play'}
                  >
                    {isPlaying ? <Pause size={18} /> : <Play size={18} style={{ marginLeft: 2 }} />}
                  </button>

                  <button
                    onClick={restartAudio}
                    style={{
                      width: 32,
                      height: 32,
                      borderRadius: '50%',
                      backgroundColor: 'var(--card-fill)',
                      border: '1px solid var(--border-light)',
                      color: 'var(--dark-navy)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      cursor: 'pointer',
                    }}
                    title="Replay from start"
                  >
                    <RotateCcw size={14} />
                  </button>

                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2 }}>
                    <input
                      type="range"
                      min={0}
                      max={duration || 100}
                      value={currentTime}
                      onChange={handleSeek}
                      style={{ width: '100%', cursor: 'pointer', accentColor: 'var(--primary-mint-dark)' }}
                    />
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: 'var(--text-muted)', fontWeight: 600 }}>
                      <span>{formatTime(currentTime)}</span>
                      <span>{formatTime(duration)}</span>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* Garment Photo Attachments Gallery */}
            {order.photoUrls && order.photoUrls.length > 0 && (
              <div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8, fontWeight: 700, fontSize: '13px', color: 'var(--dark-navy)' }}>
                  <ImageIcon size={16} color="var(--primary-mint-dark)" /> Garment Stain / Item Photos ({order.photoUrls.length}):
                </div>
                <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
                  {order.photoUrls.map((url, idx) => {
                    const resolvedUrl = resolveMediaUrl(url);
                    return (
                      <img
                        key={idx}
                        src={resolvedUrl}
                        alt={`Attachment ${idx + 1}`}
                        onClick={() => setActivePhoto(resolvedUrl)}
                        style={{ width: 84, height: 84, objectFit: 'cover', borderRadius: 8, border: '2px solid var(--border-light)', cursor: 'pointer' }}
                      />
                    );
                  })}
                </div>
              </div>
            )}
          </div>
        )}

        {/* Garment Items Table */}
        <div className="table-container" style={{ marginBottom: '20px' }}>
          <table>
            <thead>
              <tr>
                <th>Garment Service Item</th>
                <th>Quantity</th>
                <th>Unit Price</th>
                <th style={{ textAlign: 'right' }}>Total</th>
              </tr>
            </thead>
            <tbody>
              {order.items && order.items.length > 0 ? (
                order.items.map((item, idx) => (
                  <tr key={idx}>
                    <td style={{ fontWeight: 700 }}>{item.name}</td>
                    <td>{item.quantity}</td>
                    <td>₹{item.price}</td>
                    <td style={{ textAlign: 'right', fontWeight: 700 }}>₹{item.quantity * item.price}</td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={4} style={{ textAlign: 'center', color: 'var(--text-muted)' }}>Standard Dry Cleaning Order</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Payment Summary Box */}
        <div style={{ backgroundColor: 'var(--card-fill)', padding: '16px 20px', borderRadius: 'var(--radius-md)', display: 'flex', flexDirection: 'column', gap: 8 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px' }}>
            <span>Subtotal:</span>
            <span>₹{order.subtotal || order.grandTotal}</span>
          </div>
          {order.deliveryCharge > 0 && (
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px' }}>
              <span>Delivery Charge:</span>
              <span>₹{order.deliveryCharge}</span>
            </div>
          )}
          {order.handlingFee > 0 && (
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px' }}>
              <span>Express Fee:</span>
              <span>₹{order.handlingFee}</span>
            </div>
          )}
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '18px', fontWeight: 800, color: 'var(--dark-navy)', paddingTop: 8, borderTop: '1px solid var(--border-light)' }}>
            <span>Grand Total:</span>
            <span style={{ color: 'var(--primary-mint-dark)' }}>₹{order.grandTotal}</span>
          </div>
        </div>
      </div>

      {/* Photo Lightbox Popup */}
      {activePhoto && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.85)', zIndex: 2000, display: 'flex', alignItems: 'center', justifyContent: 'center' }} onClick={() => setActivePhoto(null)}>
          <img src={activePhoto} alt="Enlarged garment" style={{ maxWidth: '90%', maxHeight: '90%', borderRadius: 12 }} />
        </div>
      )}
    </div>
  );
};
