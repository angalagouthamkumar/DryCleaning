export interface User {
  id: string;
  phoneNumber: string;
  name?: string;
  email?: string;
  avatarUrl?: string;
  addresses?: Array<{
    id: string;
    label: string;
    fullAddress: string;
    landmark?: string;
    gateNotes?: string;
    lat: number;
    lng: number;
    isDefault: boolean;
  }>;
  createdAt: Date;
  updatedAt: Date;
}

// In-memory data store for quick development & demo persistence
const usersMap = new Map<string, User>();

export const UserStore = {
  findByPhone: (phoneNumber: string): User | undefined => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)]/g, '');
    for (const user of usersMap.values()) {
      if (user.phoneNumber.replace(/[\s\-\(\)]/g, '') === cleanPhone) {
        return user;
      }
    }
    return undefined;
  },

  findById: (id: string): User | undefined => {
    return usersMap.get(id);
  },

  create: (phoneNumber: string): User => {
    const cleanPhone = phoneNumber.replace(/[\s\-\(\)]/g, '');
    const newUser: User = {
      id: `usr_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
      phoneNumber: cleanPhone,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    usersMap.set(newUser.id, newUser);
    return newUser;
  },

  update: (id: string, updates: Partial<User>): User | undefined => {
    const user = usersMap.get(id);
    if (!user) return undefined;
    const updatedUser = {
      ...user,
      ...updates,
      updatedAt: new Date(),
    };
    usersMap.set(id, updatedUser);
    return updatedUser;
  }
};
