import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

const prisma = new PrismaClient();

export const signup = async (data: any) => {
  const { fullName, phone, email, password } = data;

  const existingUser = await prisma.user.findUnique({
    where: { phone },
  });

  if (existingUser) {
    throw new Error('User with this phone number already exists');
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  const user = await prisma.user.create({
    data: {
      fullName,
      phone,
      email,
      password: hashedPassword,
    },
  });

  // issue token on signup for better UX
  const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET as string, {
    expiresIn: '7d',
  });

  // strip password
  const { password: _pw, ...safeUser } = user as any;
  return { user: safeUser, token };
};

export const login = async (data: any) => {
  const { phone, password } = data;

  const user = await prisma.user.findUnique({
    where: { phone },
  });

  if (!user) {
    throw new Error('Invalid phone number or password');
  }

  const isPasswordValid = await bcrypt.compare(password, user.password);

  if (!isPasswordValid) {
    throw new Error('Invalid phone number or password');
  }

  const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET as string, {
    expiresIn: '7d', // Extended to 7 days for better user experience
  });

  // Don't return password
  const { password: _, ...userWithoutPassword } = user;

  return { user: userWithoutPassword, token };
};

export const getUserProfile = async (userId: string) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      fullName: true,
      phone: true,
      email: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  if (!user) {
    throw new Error('User not found');
  }

  return user;
};
