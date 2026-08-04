import React, { useEffect, useState } from 'react';
import { Download, Copy, ExternalLink, RefreshCw, CheckCircle, AlertCircle, Edit3, Smartphone, Bike, Layers, FileText, Calendar, HardDrive, Hash, ShieldCheck } from 'lucide-react';
import { AdminApiService } from '../services/api';
import { IApkRelease } from '../types';

interface DownloadState {
  isDownloading: boolean;
  progress: number;
  isSuccess: boolean;
  errorMsg?: string;
}

export const SystemDownloadsScreen: React.FC = () => {
  const [releases, setReleases] = useState<IApkRelease[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  
  // Download states for customer and rider apps
  const [downloadStates, setDownloadStates] = useState<Record<string, DownloadState>>({
    customer: { isDownloading: false, progress: 0, isSuccess: false },
    rider: { isDownloading: false, progress: 0, isSuccess: false },
  });

  const [copyFeedback, setCopyFeedback] = useState<Record<string, boolean>>({});

  // Admin edit modal state
  const [editingRelease, setEditingRelease] = useState<IApkRelease | null>(null);
  const [editForm, setEditForm] = useState<Partial<IApkRelease>>({});
  const [savingEdit, setSavingEdit] = useState<boolean>(false);
  const [editSuccessMsg, setEditSuccessMsg] = useState<string | null>(null);

  const fetchReleases = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await AdminApiService.getApkReleases();
      if (res.success && Array.isArray(res.data)) {
        setReleases(res.data);
      } else {
        setError('Failed to load APK release configurations.');
      }
    } catch (err: any) {
      setError(err.message || 'Error connecting to backend API.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReleases();
  }, []);

  const getRelease = (type: 'customer' | 'rider'): IApkRelease => {
    const found = releases.find((r) => r.appType === type);
    if (found) return found;

    return {
      appType: type,
      appName: type === 'customer' ? 'Customer App' : 'Rider App',
      subtitle: 'Latest Production APK',
      version: '1.0.0+1',
      buildDate: 'Aug 3, 2026',
      apkSize: type === 'customer' ? '82.3 MB' : '82.1 MB',
      releaseNotes: type === 'customer'
        ? 'Official customer mobile app release with 15-stage real-time tracking, live GPS location booking, voice instruction recording, stain photo attachments, and SemPay UPI payment integration.'
        : 'Official rider partner mobile app release with Google Maps turn-by-turn navigation, voice instruction streaming, duty toggle, task detail inspection, and instant delivery earnings ledger.',
      status: 'Production',
      downloadCount: type === 'customer' ? 124 : 68,
      apkUrl: type === 'customer' ? '/CustomerApp.apk' : '/RiderApp.apk',
    };
  };

  const resolveFullUrl = (rawUrl: string): string => {
    if (!rawUrl) return '';
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }
    const isLocal = typeof window !== 'undefined' && (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1');
    const origin = isLocal ? window.location.origin : 'https://backend-phi-five-63.vercel.app';
    return `${origin}${rawUrl.startsWith('/') ? '' : '/'}${rawUrl}`;
  };

  const validateUrl = (url: string): boolean => {
    if (!url) return false;
    try {
      const parsed = new URL(resolveFullUrl(url));
      return parsed.protocol === 'http:' || parsed.protocol === 'https:';
    } catch (_) {
      return false;
    }
  };

  // Download Handler with Progress, Success, & Error states
  const handleDownload = async (appType: 'customer' | 'rider') => {
    const release = getRelease(appType);
    const fullUrl = resolveFullUrl(release.apkUrl);

    if (!validateUrl(fullUrl)) {
      setDownloadStates((prev) => ({
        ...prev,
        [appType]: { isDownloading: false, progress: 0, isSuccess: false, errorMsg: 'Invalid or malformed APK download URL.' },
      }));
      return;
    }

    setDownloadStates((prev) => ({
      ...prev,
      [appType]: { isDownloading: true, progress: 10, isSuccess: false, errorMsg: undefined },
    }));

    try {
      // Track download count on backend asynchronously
      AdminApiService.trackApkDownload(appType).then(() => {
        setReleases((prev) =>
          prev.map((r) => (r.appType === appType ? { ...r, downloadCount: r.downloadCount + 1 } : r))
        );
      }).catch(() => {});

      // Simulate download progress steps for smooth UX
      for (let p = 25; p <= 90; p += 25) {
        await new Promise((res) => setTimeout(res, 200));
        setDownloadStates((prev) => ({
          ...prev,
          [appType]: { ...prev[appType], progress: p },
        }));
      }

      // Initiate browser download
      const link = document.createElement('a');
      link.href = fullUrl;
      link.setAttribute('download', `${release.appName.replace(/\s+/g, '')}_v${release.version}.apk`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      setDownloadStates((prev) => ({
        ...prev,
        [appType]: { isDownloading: false, progress: 100, isSuccess: true, errorMsg: undefined },
      }));

      // Reset success state after 4 seconds
      setTimeout(() => {
        setDownloadStates((prev) => ({
          ...prev,
          [appType]: { isDownloading: false, progress: 0, isSuccess: false, errorMsg: undefined },
        }));
      }, 4000);
    } catch (err: any) {
      setDownloadStates((prev) => ({
        ...prev,
        [appType]: { isDownloading: false, progress: 0, isSuccess: false, errorMsg: 'Download failed. Please try again.' },
      }));
    }
  };

  const handleCopyLink = (appType: 'customer' | 'rider') => {
    const release = getRelease(appType);
    const fullUrl = resolveFullUrl(release.apkUrl);
    navigator.clipboard.writeText(fullUrl);
    setCopyFeedback((prev) => ({ ...prev, [appType]: true }));
    setTimeout(() => {
      setCopyFeedback((prev) => ({ ...prev, [appType]: false }));
    }, 3000);
  };

  const handleOpenLink = (appType: 'customer' | 'rider') => {
    const release = getRelease(appType);
    const fullUrl = resolveFullUrl(release.apkUrl);
    if (validateUrl(fullUrl)) {
      window.open(fullUrl, '_blank', 'noopener,noreferrer');
    } else {
      alert('Invalid APK URL provided.');
    }
  };

  const openEditModal = (appType: 'customer' | 'rider') => {
    const release = getRelease(appType);
    setEditingRelease(release);
    setEditForm({
      version: release.version,
      buildDate: release.buildDate,
      apkSize: release.apkSize,
      releaseNotes: release.releaseNotes,
      status: release.status,
      apkUrl: release.apkUrl,
      subtitle: release.subtitle,
    });
    setEditSuccessMsg(null);
  };

  const handleSaveEdit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingRelease) return;
    setSavingEdit(true);
    try {
      const res = await AdminApiService.updateApkRelease(editingRelease.appType, editForm);
      if (res.success) {
        setEditSuccessMsg('APK release parameters updated dynamically!');
        setTimeout(() => {
          setEditingRelease(null);
          fetchReleases();
        }, 1200);
      }
    } catch (err: any) {
      alert(err.message || 'Failed to save changes.');
    } finally {
      setSavingEdit(false);
    }
  };

  const renderCard = (type: 'customer' | 'rider') => {
    const release = getRelease(type);
    const downloadState = downloadStates[type];
    const isCopied = copyFeedback[type];
    const isCustomer = type === 'customer';

    return (
      <div className="card" style={{ flex: 1, minWidth: '320px', display: 'flex', flexDirection: 'column', position: 'relative' }}>
        {/* Header Header */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
            <div
              style={{
                width: 48,
                height: 48,
                borderRadius: '14px',
                backgroundColor: isCustomer ? 'rgba(78, 204, 163, 0.15)' : 'rgba(232, 134, 58, 0.15)',
                color: isCustomer ? 'var(--primary-mint-dark)' : 'var(--accent-orange)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              {isCustomer ? <Smartphone size={26} /> : <Bike size={26} />}
            </div>
            <div>
              <h3 className="heading-lg" style={{ fontSize: '20px', margin: 0 }}>{release.appName}</h3>
              <p className="text-muted" style={{ fontSize: '13px', margin: 0 }}>{release.subtitle}</p>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span
              className="badge"
              style={{
                backgroundColor: release.status === 'Production' ? 'rgba(78, 204, 163, 0.15)' : 'rgba(242, 193, 78, 0.15)',
                color: release.status === 'Production' ? '#1f8563' : '#996e00',
                border: `1px solid ${release.status === 'Production' ? 'var(--primary-mint)' : 'var(--accent-gold)'}`,
              }}
            >
              <ShieldCheck size={12} /> {release.status}
            </span>
            <button
              onClick={() => openEditModal(type)}
              className="btn btn-outline"
              title="Edit APK Metadata & URL dynamically"
              style={{ padding: '6px 12px', fontSize: '12px' }}
            >
              <Edit3 size={14} /> Edit
            </button>
          </div>
        </div>

        {/* Metadata Grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(130px, 1fr))',
            gap: '12px',
            padding: '14px',
            backgroundColor: 'var(--bg-main)',
            borderRadius: 'var(--radius-sm)',
            border: '1px solid var(--border-light)',
            marginBottom: '16px',
          }}
        >
          <div>
            <span style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: 700, display: 'flex', alignItems: 'center', gap: 4 }}>
              <Hash size={12} /> CURRENT VERSION
            </span>
            <p style={{ fontSize: '15px', fontWeight: 800, color: 'var(--dark-navy)', marginTop: 2 }}>{release.version}</p>
          </div>

          <div>
            <span style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: 700, display: 'flex', alignItems: 'center', gap: 4 }}>
              <Calendar size={12} /> BUILD DATE
            </span>
            <p style={{ fontSize: '15px', fontWeight: 800, color: 'var(--dark-navy)', marginTop: 2 }}>{release.buildDate}</p>
          </div>

          <div>
            <span style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: 700, display: 'flex', alignItems: 'center', gap: 4 }}>
              <HardDrive size={12} /> APK SIZE
            </span>
            <p style={{ fontSize: '15px', fontWeight: 800, color: 'var(--dark-navy)', marginTop: 2 }}>{release.apkSize}</p>
          </div>

          <div>
            <span style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: 700, display: 'flex', alignItems: 'center', gap: 4 }}>
              <Download size={12} /> DOWNLOAD COUNT
            </span>
            <p style={{ fontSize: '15px', fontWeight: 800, color: 'var(--primary-mint-dark)', marginTop: 2 }}>{release.downloadCount.toLocaleString()}</p>
          </div>
        </div>

        {/* Release Notes */}
        <div style={{ marginBottom: '20px', flex: 1 }}>
          <span style={{ fontSize: '12px', fontWeight: 700, color: 'var(--dark-navy)', display: 'flex', alignItems: 'center', gap: 4, marginBottom: 6 }}>
            <FileText size={14} /> Release Notes
          </span>
          <p
            style={{
              fontSize: '13px',
              color: 'var(--text-primary)',
              backgroundColor: '#FFFFFF',
              padding: '12px',
              borderRadius: 'var(--radius-sm)',
              border: '1px solid var(--border-light)',
              lineHeight: 1.5,
              wordBreak: 'break-word',
            }}
          >
            {release.releaseNotes}
          </p>
        </div>

        {/* Download State Progress & Status Messages */}
        {downloadState.isDownloading && (
          <div style={{ marginBottom: '16px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', fontWeight: 700, marginBottom: 4 }}>
              <span style={{ color: 'var(--primary-mint-dark)', display: 'flex', alignItems: 'center', gap: 4 }}>
                <RefreshCw size={12} className="animate-spin" /> Preparing Production APK Download...
              </span>
              <span>{downloadState.progress}%</span>
            </div>
            <div style={{ height: 8, width: '100%', backgroundColor: 'var(--border-light)', borderRadius: 4, overflow: 'hidden' }}>
              <div style={{ height: '100%', width: `${downloadState.progress}%`, backgroundColor: 'var(--primary-mint)', transition: 'width 0.2s ease' }} />
            </div>
          </div>
        )}

        {downloadState.isSuccess && (
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 8,
              padding: '10px 14px',
              backgroundColor: 'rgba(78, 204, 163, 0.15)',
              border: '1px solid var(--primary-mint)',
              borderRadius: 'var(--radius-sm)',
              fontSize: '13px',
              fontWeight: 700,
              color: '#1f8563',
              marginBottom: '16px',
            }}
          >
            <CheckCircle size={16} /> APK Download Initiated Successfully!
          </div>
        )}

        {downloadState.errorMsg && (
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 8,
              padding: '10px 14px',
              backgroundColor: 'rgba(235, 87, 87, 0.15)',
              border: '1px solid var(--accent-coral)',
              borderRadius: 'var(--radius-sm)',
              fontSize: '13px',
              fontWeight: 700,
              color: '#b82828',
              marginBottom: '16px',
            }}
          >
            <AlertCircle size={16} /> {downloadState.errorMsg}
          </div>
        )}

        {/* Action Buttons */}
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px', marginTop: 'auto' }}>
          <button
            onClick={() => handleDownload(type)}
            disabled={downloadState.isDownloading}
            className="btn btn-primary"
            style={{ flex: '1 1 140px', padding: '12px 16px' }}
          >
            <Download size={18} /> {downloadState.isDownloading ? 'Downloading...' : 'Download APK'}
          </button>

          <button
            onClick={() => handleCopyLink(type)}
            className="btn btn-outline"
            style={{ flex: '1 1 130px', padding: '12px 16px' }}
          >
            {isCopied ? <CheckCircle size={18} color="var(--primary-mint-dark)" /> : <Copy size={18} />}
            {isCopied ? 'Link Copied!' : 'Copy Download Link'}
          </button>

          <button
            onClick={() => handleOpenLink(type)}
            className="btn btn-navy"
            style={{ padding: '12px 16px' }}
            title="Open in Browser"
          >
            <ExternalLink size={18} /> Open Link
          </button>
        </div>
      </div>
    );
  };

  return (
    <div>
      {/* Top Header */}
      <div style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'space-between', alignItems: 'center', gap: '16px', marginBottom: '24px' }}>
        <div>
          <h1 className="heading-xl">System Downloads</h1>
          <p className="text-muted">Managed production application binaries and download packages</p>
        </div>

        <button onClick={fetchReleases} className="btn btn-outline">
          <RefreshCw size={16} className={loading ? 'animate-spin' : ''} /> Refresh Status
        </button>
      </div>

      {/* Admin Notice Banner */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          padding: '14px 18px',
          backgroundColor: 'rgba(45, 58, 69, 0.04)',
          border: '1px solid var(--border-light)',
          borderRadius: 'var(--radius-md)',
          marginBottom: '28px',
          fontSize: '13px',
          color: 'var(--dark-navy)',
        }}
      >
        <Layers size={20} color="var(--primary-mint)" style={{ flexShrink: 0 }} />
        <div>
          <strong>Dynamic Binary Management:</strong> APK links and metadata are served dynamically from backend MongoDB Atlas. Click <strong>"Edit"</strong> on any card to update download URLs, version numbers, size metrics, or release notes without modifying codebase.
        </div>
      </div>

      {error && (
        <div style={{ padding: '14px 18px', backgroundColor: 'var(--accent-coral-light)', border: '1px solid var(--accent-coral)', borderRadius: 'var(--radius-md)', color: '#b82828', marginBottom: '24px' }}>
          {error}
        </div>
      )}

      {/* Download Cards Grid */}
      <div className="grid-2" style={{ gap: '24px' }}>
        {renderCard('customer')}
        {renderCard('rider')}
      </div>

      {/* Admin Dynamic Edit Modal */}
      {editingRelease && (
        <div className="modal-overlay" onClick={() => setEditingRelease(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '600px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', paddingBottom: '12px', borderBottom: '1px solid var(--border-light)' }}>
              <div>
                <h3 className="heading-md" style={{ margin: 0 }}>Update {editingRelease.appName} Release Parameters</h3>
                <p className="text-muted" style={{ fontSize: '12px', margin: 0 }}>Dynamically update download URLs and version details</p>
              </div>
              <button onClick={() => setEditingRelease(null)} style={{ fontSize: '18px', fontWeight: 800, color: 'var(--text-muted)' }}>✕</button>
            </div>

            {editSuccessMsg && (
              <div style={{ padding: '10px 14px', backgroundColor: 'var(--primary-mint-light)', border: '1px solid var(--primary-mint)', color: '#1f8563', borderRadius: 'var(--radius-sm)', marginBottom: '16px', fontWeight: 700, fontSize: '13px' }}>
                {editSuccessMsg}
              </div>
            )}

            <form onSubmit={handleSaveEdit}>
              <div className="form-group">
                <label className="form-label">Download APK URL</label>
                <input
                  type="text"
                  className="form-input"
                  value={editForm.apkUrl || ''}
                  onChange={(e) => setEditForm({ ...editForm, apkUrl: e.target.value })}
                  placeholder="/CustomerApp.apk or https://storage.com/app.apk"
                  required
                />
                <span style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: 4, display: 'block' }}>
                  Can be a relative backend path (e.g. <code>/CustomerApp.apk</code>) or an absolute external URL.
                </span>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div className="form-group">
                  <label className="form-label">Version Number</label>
                  <input
                    type="text"
                    className="form-input"
                    value={editForm.version || ''}
                    onChange={(e) => setEditForm({ ...editForm, version: e.target.value })}
                    placeholder="e.g. 1.0.1"
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Build Date</label>
                  <input
                    type="text"
                    className="form-input"
                    value={editForm.buildDate || ''}
                    onChange={(e) => setEditForm({ ...editForm, buildDate: e.target.value })}
                    placeholder="e.g. Aug 3, 2026"
                    required
                  />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div className="form-group">
                  <label className="form-label">APK Size</label>
                  <input
                    type="text"
                    className="form-input"
                    value={editForm.apkSize || ''}
                    onChange={(e) => setEditForm({ ...editForm, apkSize: e.target.value })}
                    placeholder="e.g. 82.3 MB"
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Version Status</label>
                  <select
                    className="form-select"
                    value={editForm.status || 'Production'}
                    onChange={(e) => setEditForm({ ...editForm, status: e.target.value })}
                  >
                    <option value="Production">Production</option>
                    <option value="Beta">Beta</option>
                    <option value="Deprecated">Deprecated</option>
                  </select>
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">Subtitle / Label</label>
                <input
                  type="text"
                  className="form-input"
                  value={editForm.subtitle || ''}
                  onChange={(e) => setEditForm({ ...editForm, subtitle: e.target.value })}
                  placeholder="Latest Production APK"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Release Notes</label>
                <textarea
                  className="form-input"
                  style={{ minHeight: '90px', resize: 'vertical' }}
                  value={editForm.releaseNotes || ''}
                  onChange={(e) => setEditForm({ ...editForm, releaseNotes: e.target.value })}
                  placeholder="Enter release highlights..."
                  required
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '24px' }}>
                <button type="button" onClick={() => setEditingRelease(null)} className="btn btn-outline">
                  Cancel
                </button>
                <button type="submit" disabled={savingEdit} className="btn btn-primary">
                  {savingEdit ? 'Saving Changes...' : 'Save Parameters'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default SystemDownloadsScreen;
