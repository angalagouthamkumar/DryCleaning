export const WhatsAppService = {
  sendOtpNotification: async (phoneNumber: string, code: string): Promise<boolean> => {
    let cleanPhone = phoneNumber.replace(/[\s\-\(\)\+]/g, '');
    if (cleanPhone.length === 10) {
      cleanPhone = `91${cleanPhone}`;
    }

    const message = `*Dry Cleaning & Laundry App*\nYour 6-digit verification code is: *${code}*\n\nThis code expires in 5 minutes. Do not share it with anyone.`;

    console.log(`\n==================================================`);
    console.log(`[OTP DISPATCH TO CLIENT]`);
    console.log(`Target Client Phone: ${cleanPhone}`);
    console.log(`Verification Code: ${code}`);
    console.log(`==================================================\n`);

    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    const twilioPhone = process.env.TWILIO_PHONE_NUMBER;

    if (accountSid && authToken && twilioPhone) {
      try {
        const credentials = Buffer.from(`${accountSid}:${authToken}`).toString('base64');
        const formattedPhone = cleanPhone.startsWith('+') ? cleanPhone : `+${cleanPhone}`;
        const toFormatted = twilioPhone.startsWith('whatsapp:') ? formattedPhone : formattedPhone;
        const fromPhone = twilioPhone.replace(/^whatsapp:/, '');

        console.log(`Dispatching Twilio SMS from ${fromPhone} to ${toFormatted}...`);

        const res = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`, {
          method: 'POST',
          headers: {
            'Authorization': `Basic ${credentials}`,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: new URLSearchParams({
            From: fromPhone,
            To: toFormatted,
            Body: message,
          }),
        });
        const data = await res.json();
        console.log('Twilio SMS Response:', data);
      } catch (err) {
        console.error('Twilio SMS send failed:', err);
      }
    }

    const instanceId = process.env.ULTRAMSG_INSTANCE_ID || 'instance186541';
    const token = process.env.ULTRAMSG_TOKEN || 'zbujckflu7mbn4xa';

    if (instanceId && token) {
      try {
        console.log(`Dispatching UltraMsg WhatsApp OTP to client ${cleanPhone}...`);
        const res = await fetch(`https://api.ultramsg.com/${instanceId}/messages/chat`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: new URLSearchParams({
            token: token,
            to: cleanPhone,
            body: message,
          }),
        });
        const data = await res.json();
        console.log('UltraMsg WhatsApp response for client:', data);
      } catch (err) {
        console.error('UltraMsg send failed:', err);
      }
    }

    return true;
  },

  sendOrderNotification: async (adminPhone: string, orderData: any): Promise<boolean> => {
    let cleanAdminPhone = adminPhone.replace(/[\s\-\(\)\+]/g, '');
    if (cleanAdminPhone.length === 10) {
      cleanAdminPhone = `91${cleanAdminPhone}`;
    }

    const servicesText = (orderData.services && orderData.services.length > 0)
      ? orderData.services.map((s: string) => `* ${s}`).join('\n')
      : '* Dry Cleaning';

    const itemsText = (orderData.items && orderData.items.length > 0)
      ? orderData.items.map((i: any) => `${i.quantity} ${i.name || i.title}`).join('\n')
      : '1 Garment Item';

    const message = `*New Pickup Order*\n\n` +
      `*Name:* ${orderData.customerName}\n` +
      `*Phone:* ${orderData.customerPhone}\n\n` +
      `*Address:*\n${orderData.fullAddress}${orderData.landmark ? ` (${orderData.landmark})` : ''}\n\n` +
      `*Live Location:*\n${orderData.liveLocationUrl || 'N/A'}\n\n` +
      `*Services:*\n${servicesText}\n\n` +
      `*Items:*\n${itemsText}\n\n` +
      `*Pickup:*\n${orderData.pickupDate}\n${orderData.pickupSlot}\n\n` +
      `*Notes:*\n${orderData.notes || 'None'}${orderData.hasVoiceInstruction ? '\n[Voice Instruction Attached]' : ''}${(orderData.photoUrls || []).length > 0 ? `\n[${orderData.photoUrls.length} Photo(s) Attached]` : ''}\n\n` +
      `*Payment:* ${orderData.paymentMethod} (Rs.${orderData.grandTotal})`;

    console.log(`\n==================================================`);
    console.log(`[INSTANT ULTRAMSG NEW ORDER DISPATCH TO OWNER]`);
    console.log(`Owner Phone: +${cleanAdminPhone}`);
    console.log(message);
    console.log(`==================================================\n`);

    const instanceId = process.env.ULTRAMSG_INSTANCE_ID || 'instance186541';
    const token = process.env.ULTRAMSG_TOKEN || 'zbujckflu7mbn4xa';

    if (instanceId && token) {
      try {
        const res = await fetch(`https://api.ultramsg.com/${instanceId}/messages/chat`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: new URLSearchParams({ token, to: cleanAdminPhone, body: message }),
        });
        const data = await res.json();
        console.log('UltraMsg Instant Owner Notification response:', data);
      } catch (err) {
        console.error('UltraMsg order notification failed:', err);
      }
    }

    return true;
  },

  sendOrderStatusUpdateNotification: async (adminPhone: string, orderData: any, newStatus: string): Promise<boolean> => {
    let cleanAdminPhone = adminPhone.replace(/[\s\-\(\)\+]/g, '');
    if (cleanAdminPhone.length === 10) {
      cleanAdminPhone = `91${cleanAdminPhone}`;
    }

    const isCancelled = newStatus.toLowerCase().includes('cancel');

    const statusHeader = isCancelled
      ? `*ORDER CANCELLED BY CLIENT*`
      : `*ORDER STATUS CHANGED TO ${newStatus.toUpperCase()}*`;

    const message = `${statusHeader}\n\n` +
      `*Order ID:* ${orderData.orderId || orderData.id}\n` +
      `*Customer Name:* ${orderData.customerName || 'N/A'}\n` +
      `*Customer Phone:* ${orderData.customerPhone || 'N/A'}\n\n` +
      `*Address:* ${orderData.fullAddress || 'N/A'}\n` +
      `*Amount:* Rs.${orderData.grandTotal || 0}\n` +
      `*Current Status:* *${newStatus}*\n` +
      `*Updated At:* ${new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' })}`;

    console.log(`\n==================================================`);
    console.log(`[INSTANT ULTRAMSG ORDER CANCEL/STATUS DISPATCH TO OWNER]`);
    console.log(`Owner Phone: +${cleanAdminPhone}`);
    console.log(message);
    console.log(`==================================================\n`);

    const instanceId = process.env.ULTRAMSG_INSTANCE_ID || 'instance186541';
    const token = process.env.ULTRAMSG_TOKEN || 'zbujckflu7mbn4xa';

    if (instanceId && token) {
      try {
        const res = await fetch(`https://api.ultramsg.com/${instanceId}/messages/chat`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: new URLSearchParams({ token, to: cleanAdminPhone, body: message }),
        });
        const data = await res.json();
        console.log('UltraMsg Status Update Owner Notification response:', data);
      } catch (err) {
        console.error('UltraMsg status update notification failed:', err);
      }
    }

    return true;
  }
};
