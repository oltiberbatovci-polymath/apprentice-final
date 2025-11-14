import { PrismaClient } from '@prisma/client';
import Redis from 'ioredis';

export const prisma = new PrismaClient();
export const redis = new Redis({
  host: process.env.REDIS_HOST || 'cache',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  retryStrategy: (times) => {
    const delay = Math.min(times * 50, 2000);
    return delay;
  },
});

