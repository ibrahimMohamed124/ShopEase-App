export interface Product {
  id: string;
  name: string;
  price: number;
  originalPrice?: number;
  description: string;
  category: string; // category id
  subcategory?: string; // subcategory id
  rating: number;
  reviewCount: number;
  imageUrl: string;
  badge?: string;
  inStock: boolean;
}

export interface Category {
  id: string;
  name: string;
  icon: string;
  colorHex: string;
  productCount: number;
  imageUrl: string;
  subcategories: string[];
}

export interface Subcategory {
  id: string;
  name: string;
  categoryId: string;
  imageUrl: string;
}

export type OrderStatus = "processing" | "shipped" | "delivered" | "cancelled";

export interface OrderItem {
  productId: string;
  name: string;
  imageUrl: string;
  price: number;
  quantity: number;
}

export interface Order {
  id: string;
  date: string;
  total: number;
  status: OrderStatus;
  items: OrderItem[];
  estimatedDelivery?: string;
  deliveredDate?: string;
  paymentMethod?: PaymentMethod;
  userId?: string;
  customerName?: string;
  shippingAddress?: string;
  history?: { status: OrderStatus; date: string }[];
}

export type PaymentMethodType = "visa" | "mastercard" | "amex" | "paypal" | "cashOnDelivery";

export interface PaymentMethod {
  id: string;
  type: PaymentMethodType;
  lastFour?: string;
  expiry?: string;
  holderName?: string;
  isDefault: boolean;
}

export type ReturnStatus = "inReview" | "refunded" | "rejected";

export interface ReturnRequest {
  id: string;
  orderId: string;
  productName: string;
  requestedDate: string;
  refundAmount: number;
  status: ReturnStatus;
  reason?: string;
}

export interface ProductReview {
  id: string;
  productId: string;
  userId: string;
  name: string;
  rating: number;
  date: string;
  text: string;
  verified: boolean;
  helpfulCount: number;
}

export interface AppUser {
  id: string;
  name: string;
  email: string;
  phone: string;
  address: string;
  avatarUrl?: string;
}

export interface AdminSession {
  token: string;
  refreshToken?: string;
  user: { id: string; name: string; email: string; avatarUrl?: string };
}