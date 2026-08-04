import React, { useEffect, useState } from 'react';
import { Search, Save, RotateCcw, Eye, RefreshCw, CheckCircle, FileText, AlertCircle } from 'lucide-react';
import { AdminApiService } from '../services/api';
import { IContentItem } from '../types';

const CATEGORIES = [
  'All',
  'Authentication',
  'Home',
  'Services',
  'Address',
  'Checkout',
  'Orders',
  'Profile',
  'Common',
  'Error Messages',
];

const DEFAULT_ITEMS: IContentItem[] = [
  { key: 'customer.auth.login_title', text: 'Enter Mobile Number', screen: 'LoginScreen', category: 'Authentication', component: 'HeadingText' },
  { key: 'customer.auth.login_subtitle', text: 'We will send you a 6-digit verification code via WhatsApp/SMS', screen: 'LoginScreen', category: 'Authentication', component: 'SubheadingText' },
  { key: 'customer.auth.phone_placeholder', text: 'Enter 10-digit mobile number', screen: 'LoginScreen', category: 'Authentication', component: 'PhoneInputField' },
  { key: 'customer.auth.send_otp_button', text: 'Send OTP Code', screen: 'LoginScreen', category: 'Authentication', component: 'PrimaryButton' },
  { key: 'customer.auth.otp_title', text: 'Verify Phone', screen: 'OtpScreen', category: 'Authentication', component: 'HeadingText' },
  { key: 'customer.auth.otp_subtitle', text: 'Enter the 6-digit code sent to your mobile number', screen: 'OtpScreen', category: 'Authentication', component: 'SubheadingText' },
  { key: 'customer.auth.resend_prompt', text: "Didn't receive the code?", screen: 'OtpScreen', category: 'Authentication', component: 'TextLabel' },
  { key: 'customer.auth.resend_button', text: 'Resend Verification Code', screen: 'OtpScreen', category: 'Authentication', component: 'TextButton' },
  { key: 'customer.auth.resend_timer', text: 'Resend code in {time}', screen: 'OtpScreen', category: 'Authentication', component: 'TimerLabel' },
  { key: 'customer.auth.verify_button', text: 'Verify & Proceed', screen: 'OtpScreen', category: 'Authentication', component: 'PrimaryButton' },
  { key: 'customer.auth.otp_sent_snackbar', text: 'A new 6-digit verification code has been dispatched.', screen: 'OtpScreen', category: 'Authentication', component: 'Snackbar' },
  { key: 'customer.auth.invalid_otp_error', text: 'Please enter the complete 6-digit verification code.', screen: 'OtpScreen', category: 'Authentication', component: 'ValidationError' },

  { key: 'customer.home.app_header_title', text: 'DryCleaning & Laundry', screen: 'HomeScreen', category: 'Home', component: 'AppBar' },
  { key: 'customer.home.search_placeholder', text: 'Search for services, dry cleaning, ironing...', screen: 'HomeScreen', category: 'Home', component: 'AnimatedSearchBar' },
  { key: 'customer.home.banner_title', text: 'Fastest Doorstep Laundry & Dry Cleaning', screen: 'HomeScreen', category: 'Home', component: 'BannerCard' },
  { key: 'customer.home.banner_subtitle', text: 'Cleaned, steam ironed, & delivered within 24 Hours', screen: 'HomeScreen', category: 'Home', component: 'BannerCard' },
  { key: 'customer.home.book_now_button', text: 'Book Now', screen: 'HomeScreen', category: 'Home', component: 'BannerButton' },
  { key: 'customer.home.popular_services_header', text: 'Popular Dry Cleaning Services', screen: 'HomeScreen', category: 'Home', component: 'SectionHeader' },
  { key: 'customer.home.packages_header', text: 'Packages & Subscriptions', screen: 'HomeScreen', category: 'Home', component: 'SectionHeader' },

  // Services & Garments
  { key: 'customer.services.category_all', text: 'All Services', screen: 'HomeScreen', category: 'Services', component: 'CategoryFilterTab' },
  { key: 'customer.services.category_dry_cleaning', text: 'Dry Cleaning', screen: 'HomeScreen', category: 'Services', component: 'CategoryFilterTab' },
  { key: 'customer.services.category_wash_fold', text: 'Wash & Fold', screen: 'HomeScreen', category: 'Services', component: 'CategoryFilterTab' },
  { key: 'customer.services.category_wash_iron', text: 'Wash & Iron', screen: 'HomeScreen', category: 'Services', component: 'CategoryFilterTab' },
  { key: 'customer.services.category_steam_iron', text: 'Steam Iron', screen: 'HomeScreen', category: 'Services', component: 'CategoryFilterTab' },
  { key: 'customer.services.category_household', text: 'Household & Curtains', screen: 'HomeScreen', category: 'Services', component: 'CategoryFilterTab' },
  { key: 'customer.services.category_shoe_care', text: 'Shoe Care', screen: 'HomeScreen', category: 'Services', component: 'CategoryFilterTab' },

  { key: 'customer.services.s1_title', text: "Men's Shirt / T-Shirt", screen: 'HomeScreen', category: 'Services', component: 'GarmentServiceCard' },
  { key: 'customer.services.s1_price', text: '₹60', screen: 'HomeScreen', category: 'Services', component: 'GarmentPriceTag' },
  { key: 'customer.services.s1_original_price', text: '₹80', screen: 'HomeScreen', category: 'Services', component: 'GarmentOriginalPrice' },

  { key: 'customer.services.s2_title', text: 'Trousers / Jeans', screen: 'HomeScreen', category: 'Services', component: 'GarmentServiceCard' },
  { key: 'customer.services.s2_price', text: '₹70', screen: 'HomeScreen', category: 'Services', component: 'GarmentPriceTag' },

  { key: 'customer.services.s3_title', text: '2-Piece Suit', screen: 'HomeScreen', category: 'Services', component: 'GarmentServiceCard' },
  { key: 'customer.services.s3_price', text: '₹250', screen: 'HomeScreen', category: 'Services', component: 'GarmentPriceTag' },
  { key: 'customer.services.s3_original_price', text: '₹300', screen: 'HomeScreen', category: 'Services', component: 'GarmentOriginalPrice' },

  { key: 'customer.services.s4_title', text: 'Silk Saree / Heavy Lehenga', screen: 'HomeScreen', category: 'Services', component: 'GarmentServiceCard' },
  { key: 'customer.services.s4_price', text: '₹180', screen: 'HomeScreen', category: 'Services', component: 'GarmentPriceTag' },

  { key: 'customer.services.s5_title', text: 'Wash & Fold (per kg)', screen: 'HomeScreen', category: 'Services', component: 'GarmentServiceCard' },
  { key: 'customer.services.s5_price', text: '₹50', screen: 'HomeScreen', category: 'Services', component: 'GarmentPriceTag' },

  { key: 'customer.services.s6_title', text: 'Daily Wear Wash & Iron', screen: 'HomeScreen', category: 'Services', component: 'GarmentServiceCard' },
  { key: 'customer.services.s6_price', text: '₹80', screen: 'HomeScreen', category: 'Services', component: 'GarmentPriceTag' },

  { key: 'customer.services.s7_title', text: 'Steam Iron Shirt/Top', screen: 'HomeScreen', category: 'Services', component: 'GarmentServiceCard' },
  { key: 'customer.services.s7_price', text: '₹25', screen: 'HomeScreen', category: 'Services', component: 'GarmentPriceTag' },

  { key: 'customer.services.s8_title', text: 'Double Blanket / Quilt', screen: 'HomeScreen', category: 'Services', component: 'GarmentServiceCard' },
  { key: 'customer.services.s8_price', text: '₹350', screen: 'HomeScreen', category: 'Services', component: 'GarmentPriceTag' },
  { key: 'customer.services.s8_original_price', text: '₹400', screen: 'HomeScreen', category: 'Services', component: 'GarmentOriginalPrice' },

  { key: 'customer.services.s9_title', text: 'Curtain Dry Clean (per panel)', screen: 'HomeScreen', category: 'Services', component: 'GarmentServiceCard' },
  { key: 'customer.services.s9_price', text: '₹120', screen: 'HomeScreen', category: 'Services', component: 'GarmentPriceTag' },

  { key: 'customer.services.s10_title', text: 'Sneaker Cleaning & Polish', screen: 'HomeScreen', category: 'Services', component: 'GarmentServiceCard' },
  { key: 'customer.services.s10_price', text: '₹299', screen: 'HomeScreen', category: 'Services', component: 'GarmentPriceTag' },

  // Garment Packages & Subscriptions
  { key: 'customer.services.p1_title', text: 'Weekly Laundry Pack', screen: 'HomeScreen', category: 'Services', component: 'PackageCard' },
  { key: 'customer.services.p1_subtitle', text: '5 Shirts + 3 Trousers', screen: 'HomeScreen', category: 'Services', component: 'PackageSubtitle' },
  { key: 'customer.services.p1_price', text: '₹349', screen: 'HomeScreen', category: 'Services', component: 'PackagePrice' },

  { key: 'customer.services.p2_title', text: 'Office Wear Pack', screen: 'HomeScreen', category: 'Services', component: 'PackageCard' },
  { key: 'customer.services.p2_subtitle', text: '4 Suits + 4 Ties', screen: 'HomeScreen', category: 'Services', component: 'PackageSubtitle' },
  { key: 'customer.services.p2_price', text: '₹599', screen: 'HomeScreen', category: 'Services', component: 'PackagePrice' },

  { key: 'customer.services.p3_title', text: 'Family Pack', screen: 'HomeScreen', category: 'Services', component: 'PackageCard' },
  { key: 'customer.services.p3_subtitle', text: '15 Mixed Items Wash & Iron', screen: 'HomeScreen', category: 'Services', component: 'PackageSubtitle' },
  { key: 'customer.services.p3_price', text: '₹899', screen: 'HomeScreen', category: 'Services', component: 'PackagePrice' },

  { key: 'customer.services.add_button', text: 'ADD', screen: 'HomeScreen', category: 'Services', component: 'QuantityButton' },

  { key: 'customer.address.title', text: 'Delivery Address', screen: 'CheckoutScreen', category: 'Address', component: 'SectionHeader' },
  { key: 'customer.address.house_no_placeholder', text: 'House / Flat / Block No.', screen: 'CheckoutScreen', category: 'Address', component: 'TextInput' },
  { key: 'customer.address.landmark_placeholder', text: 'Landmark (e.g. Near Apollo Pharmacy)', screen: 'CheckoutScreen', category: 'Address', component: 'TextInput' },
  { key: 'customer.address.full_address_placeholder', text: 'Full Doorstep Address', screen: 'CheckoutScreen', category: 'Address', component: 'TextInput' },
  { key: 'customer.address.detect_location_button', text: 'Detect Current GPS Location', screen: 'CheckoutScreen', category: 'Address', component: 'LocationButton' },

  { key: 'customer.checkout.header_title', text: 'Checkout & Schedule', screen: 'CheckoutScreen', category: 'Checkout', component: 'AppBar' },
  { key: 'customer.checkout.pickup_slot_title', text: 'Select Pickup & Delivery Slot', screen: 'CheckoutScreen', category: 'Checkout', component: 'SectionHeader' },
  { key: 'customer.checkout.express_slot_option', text: 'Express Fast Pickup & Delivery', screen: 'CheckoutScreen', category: 'Checkout', component: 'RadioButton' },
  { key: 'customer.checkout.payment_method_title', text: 'Select Payment Mode', screen: 'CheckoutScreen', category: 'Checkout', component: 'SectionHeader' },
  { key: 'customer.checkout.payment_cod', text: 'Cash on Delivery (COD)', screen: 'CheckoutScreen', category: 'Checkout', component: 'PaymentOptionCard' },
  { key: 'customer.checkout.payment_sempay_upi', text: 'SemPay Instant UPI Payment', screen: 'CheckoutScreen', category: 'Checkout', component: 'PaymentOptionCard' },
  { key: 'customer.checkout.place_order_button', text: 'Place Order Now', screen: 'CheckoutScreen', category: 'Checkout', component: 'PrimaryButton' },
  { key: 'customer.checkout.order_success_dialog_title', text: 'Order Placed Successfully!', screen: 'CheckoutScreen', category: 'Checkout', component: 'AlertDialog' },

  { key: 'customer.orders.tab_active', text: 'Active Orders', screen: 'OrdersScreen', category: 'Orders', component: 'SegmentedTab' },
  { key: 'customer.orders.tab_past', text: 'Past History', screen: 'OrdersScreen', category: 'Orders', component: 'SegmentedTab' },
  { key: 'customer.orders.empty_active_title', text: 'No active laundry orders', screen: 'OrdersScreen', category: 'Orders', component: 'EmptyStateCard' },
  { key: 'customer.orders.empty_active_subtitle', text: 'Place an order from home screen to get live status updates', screen: 'OrdersScreen', category: 'Orders', component: 'EmptyStateCard' },
  { key: 'customer.orders.stage_placed', text: 'Placed', screen: 'OrdersScreen', category: 'Orders', component: 'TimelineTracker' },
  { key: 'customer.orders.stage_confirmed', text: 'Confirmed', screen: 'OrdersScreen', category: 'Orders', component: 'TimelineTracker' },
  { key: 'customer.orders.stage_picked_up', text: 'Picked Up', screen: 'OrdersScreen', category: 'Orders', component: 'TimelineTracker' },
  { key: 'customer.orders.stage_in_cleaning', text: 'In Cleaning', screen: 'OrdersScreen', category: 'Orders', component: 'TimelineTracker' },
  { key: 'customer.orders.stage_ready', text: 'Ready', screen: 'OrdersScreen', category: 'Orders', component: 'TimelineTracker' },
  { key: 'customer.orders.stage_out_for_delivery', text: 'Out for Delivery', screen: 'OrdersScreen', category: 'Orders', component: 'TimelineTracker' },
  { key: 'customer.orders.stage_delivered', text: 'Delivered', screen: 'OrdersScreen', category: 'Orders', component: 'TimelineTracker' },
  { key: 'customer.orders.cancel_button', text: 'Cancel Order', screen: 'OrdersScreen', category: 'Orders', component: 'OutlinedButton' },
  { key: 'customer.orders.cancel_dialog_title', text: 'Cancel Order?', screen: 'OrdersScreen', category: 'Orders', component: 'AlertDialog' },
  { key: 'customer.orders.cancel_dialog_confirm', text: 'Confirm Cancel', screen: 'OrdersScreen', category: 'Orders', component: 'DialogButton' },
  { key: 'customer.orders.cancel_dialog_keep', text: 'Keep Order', screen: 'OrdersScreen', category: 'Orders', component: 'DialogButton' },

  { key: 'customer.profile.title', text: 'My Profile', screen: 'ProfileScreen', category: 'Profile', component: 'AppBar' },
  { key: 'customer.profile.logout_button', text: 'Logout Account', screen: 'ProfileScreen', category: 'Profile', component: 'PrimaryButton' },
  { key: 'customer.profile.logout_dialog_title', text: 'Confirm Logout', screen: 'ProfileScreen', category: 'Profile', component: 'AlertDialog' },
  { key: 'customer.profile.logout_dialog_confirm', text: 'Logout', screen: 'ProfileScreen', category: 'Profile', component: 'DialogButton' },

  { key: 'customer.common.loading', text: 'Loading...', screen: 'Global', category: 'Common', component: 'ProgressIndicator' },
  { key: 'customer.common.something_went_wrong', text: 'Something went wrong. Please try again.', screen: 'Global', category: 'Error Messages', component: 'Toast' },
  { key: 'customer.common.network_error', text: 'Network connection lost. Please check internet connection.', screen: 'Global', category: 'Error Messages', component: 'Toast' },
];

export const ContentManagementScreen: React.FC = () => {
  const [items, setItems] = useState<IContentItem[]>(DEFAULT_ITEMS);
  const [editedItems, setEditedItems] = useState<Record<string, string>>({});
  const [activeCategory, setActiveCategory] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [showPreviewModal, setShowPreviewModal] = useState(false);
  const [saveSuccessMessage, setSaveSuccessMessage] = useState<string | null>(null);

  const fetchContent = async (showLoading = false) => {
    if (showLoading) setLoading(true);
    try {
      const res = await AdminApiService.getContent();
      const loadedData = Array.isArray(res) ? res : (Array.isArray(res?.data) ? res.data : []);
      if (loadedData.length > 0) {
        setItems(loadedData);
      } else {
        setItems(DEFAULT_ITEMS);
      }
    } catch (err) {
      console.error('Failed to fetch content items, using default list:', err);
      setItems(DEFAULT_ITEMS);
    } finally {
      if (showLoading) setLoading(false);
    }
  };

  useEffect(() => {
    fetchContent(true);
  }, []);

  const handleTextChange = (key: string, newText: string) => {
    setEditedItems((prev) => ({
      ...prev,
      [key]: newText,
    }));
  };

  const handleResetUnsaved = () => {
    setEditedItems({});
  };

  const handleSaveAll = async () => {
    const keysToSave = Object.keys(editedItems);
    if (keysToSave.length === 0) return;

    // Validation: prevent empty strings
    for (const key of keysToSave) {
      if (editedItems[key].trim() === '') {
        alert(`Content key "${key}" cannot be empty.`);
        return;
      }
    }

    setIsSaving(true);
    try {
      const payload = keysToSave.map((key) => ({
        key,
        text: editedItems[key],
      }));

      const res = await AdminApiService.bulkUpdateContent(payload);
      if (res.success) {
        setEditedItems({});
        setShowPreviewModal(false);
        setSaveSuccessMessage(`${payload.length} text entry(s) updated successfully!`);
        setTimeout(() => setSaveSuccessMessage(null), 4000);
        fetchContent(false);
      }
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to save content changes.');
    } finally {
      setIsSaving(false);
    }
  };

  const filteredItems = items.filter((item) => {
    const q = searchQuery.toLowerCase();
    const matchesSearch =
      item.key.toLowerCase().includes(q) ||
      item.text.toLowerCase().includes(q) ||
      item.screen.toLowerCase().includes(q) ||
      item.category.toLowerCase().includes(q);

    if (!matchesSearch) return false;
    if (activeCategory === 'All') return true;
    return item.category.toLowerCase() === activeCategory.toLowerCase();
  });

  const modifiedKeys = Object.keys(editedItems).filter((key) => {
    const original = items.find((i) => i.key === key);
    return original && original.text !== editedItems[key];
  });

  return (
    <div>
      {/* Title Header & Main Controls */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: 16 }}>
        <div>
          <h1 className="heading-xl">Customer App Content Management</h1>
          <p className="text-muted">Manage and update all Customer App frontend text dynamically in real time</p>
        </div>

        <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
          <button
            onClick={() => fetchContent(true)}
            className="btn btn-outline"
            style={{ display: 'flex', alignItems: 'center', gap: 6 }}
          >
            <RefreshCw size={16} className={loading ? 'animate-spin' : ''} /> Refresh
          </button>

          {modifiedKeys.length > 0 && (
            <>
              <button
                onClick={handleResetUnsaved}
                className="btn btn-outline"
                style={{ color: '#EF4444', borderColor: '#FCA5A5', display: 'flex', alignItems: 'center', gap: 6 }}
              >
                <RotateCcw size={16} /> Reset Unsaved ({modifiedKeys.length})
              </button>

              <button
                onClick={() => setShowPreviewModal(true)}
                className="btn btn-outline"
                style={{ display: 'flex', alignItems: 'center', gap: 6 }}
              >
                <Eye size={16} /> Preview ({modifiedKeys.length})
              </button>

              <button
                onClick={handleSaveAll}
                disabled={isSaving}
                className="btn btn-primary"
                style={{ display: 'flex', alignItems: 'center', gap: 6 }}
              >
                <Save size={16} /> {isSaving ? 'Saving...' : `Save All Changes (${modifiedKeys.length})`}
              </button>
            </>
          )}
        </div>
      </div>

      {/* Success Notification Banner */}
      {saveSuccessMessage && (
        <div style={{ backgroundColor: '#ECFDF5', border: '1px solid #6EE7B7', color: '#065F46', padding: '12px 16px', borderRadius: '12px', marginBottom: '20px', display: 'flex', alignItems: 'center', gap: 10 }}>
          <CheckCircle size={20} color="#10B981" />
          <span style={{ fontWeight: 700, fontSize: '14px' }}>{saveSuccessMessage}</span>
        </div>
      )}

      {/* Category Tabs & Global Search */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: 16 }}>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          {CATEGORIES.map((cat) => {
            const isActive = activeCategory === cat;
            const count = cat === 'All' ? items.length : items.filter((i) => i.category.toLowerCase() === cat.toLowerCase()).length;
            return (
              <button
                key={cat}
                className={`btn ${isActive ? 'btn-primary' : 'btn-outline'}`}
                onClick={() => setActiveCategory(cat)}
                style={{ borderRadius: 'var(--radius-pill)', padding: '6px 14px', fontSize: '13px' }}
              >
                {cat} ({count})
              </button>
            );
          })}
        </div>

        <div style={{ minWidth: '300px', position: 'relative' }}>
          <Search size={18} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
          <input
            type="text"
            className="form-input"
            style={{ paddingLeft: 42, borderRadius: 'var(--radius-pill)', backgroundColor: '#ffffff' }}
            placeholder="Search by key, text, screen, or category..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      {/* Content Editor Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(480px, 1fr))', gap: '16px' }}>
        {filteredItems.map((item) => {
          const currentText = editedItems[item.key] !== undefined ? editedItems[item.key] : item.text;
          const isModified = editedItems[item.key] !== undefined && editedItems[item.key] !== item.text;
          const charLimit = item.maxLength || 200;

          return (
            <div
              key={item.key}
              className="card"
              style={{
                borderLeft: isModified ? '4px solid #F59E0B' : '1px solid var(--border-color)',
                backgroundColor: isModified ? '#FFFBEB' : '#ffffff',
                padding: '20px',
              }}
            >
              {/* Header Info */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 12 }}>
                <div style={{ flex: 1, paddingRight: 10 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6, flexWrap: 'wrap' }}>
                    <code style={{ fontSize: '12px', fontWeight: 800, color: 'var(--dark-navy)', backgroundColor: '#E2E8F0', padding: '2px 8px', borderRadius: '6px' }}>
                      {item.key}
                    </code>
                    {isModified && (
                      <span className="badge badge-warning" style={{ fontSize: '10px' }}>
                        MODIFIED
                      </span>
                    )}
                  </div>
                  <div style={{ display: 'flex', gap: 8, marginTop: 6, fontSize: '11px', color: 'var(--text-muted)' }}>
                    <span><strong>Screen:</strong> {item.screen}</span>
                    {item.component && <span><strong>Component:</strong> {item.component}</span>}
                  </div>
                </div>
                <span className="badge badge-neutral" style={{ fontSize: '11px' }}>
                  {item.category}
                </span>
              </div>

              {/* Editable Text Area */}
              <div>
                <textarea
                  className="form-input"
                  rows={2}
                  style={{
                    width: '100%',
                    resize: 'vertical',
                    fontFamily: 'inherit',
                    fontSize: '14px',
                    borderColor: isModified ? '#F59E0B' : 'var(--border-color)',
                  }}
                  value={currentText}
                  onChange={(e) => handleTextChange(item.key, e.target.value)}
                />
              </div>

              {/* Character Limit Indicator */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 8, fontSize: '11px', color: 'var(--text-muted)' }}>
                <span>Original: <em>"{item.text}"</em></span>
                <span style={{ color: currentText.length > charLimit ? '#EF4444' : 'inherit', fontWeight: currentText.length > charLimit ? 800 : 500 }}>
                  {currentText.length} / {charLimit} chars
                </span>
              </div>
            </div>
          );
        })}
      </div>

      {filteredItems.length === 0 && (
        <div className="card" style={{ textAlign: 'center', padding: '48px', color: 'var(--text-muted)' }}>
          <FileText size={48} style={{ marginBottom: 12, opacity: 0.5 }} />
          <h3 className="heading-md">No Content Keys Found</h3>
          <p className="text-muted">No text entries match your search query or category filter.</p>
        </div>
      )}

      {/* Live Preview Modal */}
      {showPreviewModal && (
        <div className="modal-overlay" onClick={() => setShowPreviewModal(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '700px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h2 className="heading-lg">Preview Pending Content Changes</h2>
              <button onClick={() => setShowPreviewModal(false)} className="btn btn-outline">Close</button>
            </div>

            <p className="text-muted" style={{ marginBottom: 16 }}>
              Review the updated text entries below before saving to the live database.
            </p>

            <div style={{ maxHeight: '350px', overflowY: 'auto', marginBottom: 20 }}>
              <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                <thead>
                  <tr style={{ backgroundColor: 'var(--bg-light)', textAlign: 'left', borderBottom: '1px solid var(--border-color)' }}>
                    <th style={{ padding: '10px' }}>Content Key</th>
                    <th style={{ padding: '10px' }}>Original Text</th>
                    <th style={{ padding: '10px' }}>Updated Text</th>
                  </tr>
                </thead>
                <tbody>
                  {modifiedKeys.map((key) => {
                    const original = items.find((i) => i.key === key);
                    return (
                      <tr key={key} style={{ borderBottom: '1px solid var(--border-color)' }}>
                        <td style={{ padding: '10px', fontSize: '11px', fontWeight: 800, fontFamily: 'monospace' }}>{key}</td>
                        <td style={{ padding: '10px', fontSize: '13px', color: '#EF4444' }}>{original?.text}</td>
                        <td style={{ padding: '10px', fontSize: '13px', color: '#10B981', fontWeight: 700 }}>{editedItems[key]}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 10 }}>
              <button onClick={() => setShowPreviewModal(false)} className="btn btn-outline">Cancel</button>
              <button onClick={handleSaveAll} disabled={isSaving} className="btn btn-primary">
                {isSaving ? 'Saving Changes...' : 'Confirm & Save All Changes'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
