import mongoose, { Schema, Document } from 'mongoose';

export interface IContentItem extends Document {
  key: string;
  text: string;
  screen: string;
  category: string;
  component?: string;
  maxLength?: number;
  updatedAt: Date;
}

const ContentSchema = new Schema<IContentItem>({
  key: { type: String, required: true, unique: true },
  text: { type: String, required: true },
  screen: { type: String, required: true },
  category: { type: String, required: true },
  component: { type: String },
  maxLength: { type: Number, default: 200 },
  updatedAt: { type: Date, default: Date.now },
});

export const ContentModel = mongoose.model<IContentItem>('Content', ContentSchema);

export const DEFAULT_CUSTOMER_CONTENT = [
  // Authentication
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

  // Home
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

  // Address
  { key: 'customer.address.title', text: 'Delivery Address', screen: 'CheckoutScreen', category: 'Address', component: 'SectionHeader' },
  { key: 'customer.address.house_no_placeholder', text: 'House / Flat / Block No.', screen: 'CheckoutScreen', category: 'Address', component: 'TextInput' },
  { key: 'customer.address.landmark_placeholder', text: 'Landmark (e.g. Near Apollo Pharmacy)', screen: 'CheckoutScreen', category: 'Address', component: 'TextInput' },
  { key: 'customer.address.full_address_placeholder', text: 'Full Doorstep Address', screen: 'CheckoutScreen', category: 'Address', component: 'TextInput' },
  { key: 'customer.address.detect_location_button', text: 'Detect Current GPS Location', screen: 'CheckoutScreen', category: 'Address', component: 'LocationButton' },

  // Checkout
  { key: 'customer.checkout.header_title', text: 'Checkout & Schedule', screen: 'CheckoutScreen', category: 'Checkout', component: 'AppBar' },
  { key: 'customer.checkout.pickup_slot_title', text: 'Select Pickup & Delivery Slot', screen: 'CheckoutScreen', category: 'Checkout', component: 'SectionHeader' },
  { key: 'customer.checkout.express_slot_option', text: 'Express Fast Pickup & Delivery', screen: 'CheckoutScreen', category: 'Checkout', component: 'RadioButton' },
  { key: 'customer.checkout.payment_method_title', text: 'Select Payment Mode', screen: 'CheckoutScreen', category: 'Checkout', component: 'SectionHeader' },
  { key: 'customer.checkout.payment_cod', text: 'Cash on Delivery (COD)', screen: 'CheckoutScreen', category: 'Checkout', component: 'PaymentOptionCard' },
  { key: 'customer.checkout.payment_sempay_upi', text: 'SemPay Instant UPI Payment', screen: 'CheckoutScreen', category: 'Checkout', component: 'PaymentOptionCard' },
  { key: 'customer.checkout.place_order_button', text: 'Place Order Now', screen: 'CheckoutScreen', category: 'Checkout', component: 'PrimaryButton' },
  { key: 'customer.checkout.order_success_dialog_title', text: 'Order Placed Successfully!', screen: 'CheckoutScreen', category: 'Checkout', component: 'AlertDialog' },

  // Orders
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

  // Profile
  { key: 'customer.profile.title', text: 'My Profile', screen: 'ProfileScreen', category: 'Profile', component: 'AppBar' },
  { key: 'customer.profile.logout_button', text: 'Logout Account', screen: 'ProfileScreen', category: 'Profile', component: 'PrimaryButton' },
  { key: 'customer.profile.logout_dialog_title', text: 'Confirm Logout', screen: 'ProfileScreen', category: 'Profile', component: 'AlertDialog' },
  { key: 'customer.profile.logout_dialog_confirm', text: 'Logout', screen: 'ProfileScreen', category: 'Profile', component: 'DialogButton' },

  // Common & Errors
  { key: 'customer.common.loading', text: 'Loading...', screen: 'Global', category: 'Common', component: 'ProgressIndicator' },
  { key: 'customer.common.something_went_wrong', text: 'Something went wrong. Please try again.', screen: 'Global', category: 'Error Messages', component: 'Toast' },
  { key: 'customer.common.network_error', text: 'Network connection lost. Please check internet connection.', screen: 'Global', category: 'Error Messages', component: 'Toast' }
];
