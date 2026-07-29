export const WhatsAppService = {
  sendOtpNotification: async (phoneNumber: string, code: string): Promise<boolean> => {
    const provider = process.env.WHATSAPP_PROVIDER || 'mock';
    const message = `🧺 *Dry Cleaning & Laundry App*\nYour 6-digit verification code is: *${code}*\n\nThis code expires in 5 minutes. Do not share it with anyone.`;

    console.log(`\n==================================================`);
    console.log(`💬 [WHATSAPP OTP DISPATCH - Provider: ${provider.toUpperCase()}]`);
    console.log(`📲 To: ${phoneNumber}`);
    console.log(`🔑 Verification Code: ${code}`);
    console.log(`==================================================\n`);

    // 1. Twilio Integration (Physical SMS & WhatsApp)
    if (provider === 'twilio' || process.env.TWILIO_ACCOUNT_SID) {
      const accountSid = process.env.TWILIO_ACCOUNT_SID;
      const authToken = process.env.TWILIO_AUTH_TOKEN;
      const twilioPhone = process.env.TWILIO_PHONE_NUMBER;

      if (accountSid && authToken && twilioPhone) {
        try {
          const credentials = Buffer.from(`${accountSid}:${authToken}`).toString('base64');
          const cleanPhone = phoneNumber.startsWith('+') ? phoneNumber : `+91${phoneNumber.replace(/\D/g, '').slice(-10)}`;
          const toFormatted = twilioPhone.startsWith('whatsapp:') ? (cleanPhone.startsWith('whatsapp:') ? cleanPhone : `whatsapp:${cleanPhone}`) : cleanPhone;

          console.log(`💬 Dispatching Twilio message from ${twilioPhone} to ${toFormatted}...`);

          const res = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`, {
            method: 'POST',
            headers: {
              'Authorization': `Basic ${credentials}`,
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
              From: twilioPhone,
              To: toFormatted,
              Body: message,
            }),
          });
          const data = await res.json();
          console.log('✅ Twilio SMS Response:', data);
        } catch (err) {
          console.error('❌ Twilio send failed:', err);
        }
      }
    }

    // 2. UltraMsg Integration (WhatsApp Inbox)
    const instanceId = process.env.ULTRAMSG_INSTANCE_ID;
    const token = process.env.ULTRAMSG_TOKEN;
    if (instanceId && token) {
      try {
        const cleanPhone = phoneNumber.replace(/[\s\-\(\)\+]/g, '');
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
        console.log('✅ UltraMsg WhatsApp response:', data);
      } catch (err) {
        console.error('❌ UltraMsg send failed:', err);
      }
    }

    return true;

    // Mock Mode (Development Default)
    return true;
  },

  sendOrderNotification: async (adminPhone: string, orderData: any): Promise<boolean> => {
    const servicesText = (orderData.services && orderData.services.length > 0)
      ? orderData.services.map((s: string) => `• ${s}`).join('\n')
      : '• Dry Cleaning';

    const itemsText = (orderData.items && orderData.items.length > 0)
      ? orderData.items.map((i: any) => `${i.quantity} ${i.name || i.title}`).join('\n')
      : '1 Garment Item';

    const message = `🧺 *New Pickup Order*\n\n` +
      `👤 *Name:* ${orderData.customerName}\n` +
      `📞 *Phone:* ${orderData.customerPhone}\n\n` +
      `📍 *Address:*\n${orderData.fullAddress}${orderData.landmark ? ` (${orderData.landmark})` : ''}\n\n` +
      `🗺️ *Live Location:*\n${orderData.liveLocationUrl || 'N/A'}\n\n` +
      `🧥 *Services:*\n${servicesText}\n\n` +
      `👕 *Items:*\n${itemsText}\n\n` +
      `📅 *Pickup:*\n${orderData.pickupDate}\n${orderData.pickupSlot}\n\n` +
      `📝 *Notes:*\n${orderData.notes || 'None'}${orderData.hasVoiceInstruction ? '\n🎤 [Voice Instruction Attached]' : ''}${(orderData.photoUrls || []).length > 0 ? `\n📷 [${orderData.photoUrls.length} Photo(s) Attached]` : ''}\n\n` +
      `💳 *Payment:* ${orderData.paymentMethod} (₹${orderData.grandTotal})`;

    console.log(`\n==================================================`);
    console.log(`💬 [INSTANT ULTRAMSG ORDER DISPATCH TO OWNER]`);
    console.log(`📲 Owner Phone: +${adminPhone}`);
    console.log(message);
    console.log(`==================================================\n`);

    const instanceId = process.env.ULTRAMSG_INSTANCE_ID || 'instance186541';
    const token = process.env.ULTRAMSG_TOKEN || 'zbujckflu7mbn4xa';

    if (instanceId && token) {
      try {
        const cleanPhone = adminPhone.replace(/[\s\-\(\)\+]/g, '');
        const res = await fetch(`https://api.ultramsg.com/${instanceId}/messages/chat`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: new URLSearchParams({ token, to: cleanPhone, body: message }),
        });
        const data = await res.json();
        console.log('✅ UltraMsg Instant Owner Notification response:', data);
      } catch (err) {
        console.error('❌ UltraMsg order notification failed:', err);
      }
    }

    return true;
  }
};

