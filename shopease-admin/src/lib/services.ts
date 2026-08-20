import { api } from "./api-client";
import { endpoints, isMockMode } from "./api-config";
import {
  mockCategories,
  mockOrders,
  mockPaymentMethods,
  mockProducts,
  mockReturns,
  mockReviews,
  mockSubcategories,
  mockUsers,
} from "./mock-data";
import type {
  AdminSession,
  AppUser,
  Category,
  Order,
  OrderStatus,
  PaymentMethod,
  Product,
  ProductReview,
  ReturnRequest,
  ReturnStatus,
  Subcategory,
} from "./types";

/**
 * Service layer. In mock mode everything resolves from local sample data so
 * the UI renders without a backend; flip mock mode off in Settings to hit the
 * real REST API through the typed client.
 */
const delay = <T,>(value: T) => new Promise<T>((resolve) => setTimeout(() => resolve(value), 120));

export const authService = {
  login: async (email: string, password: string): Promise<AdminSession> => {
    if (isMockMode()) {
      if (!email || !password) throw new Error("Email and password are required");
      return delay({
        token: "mock-jwt-token",
        refreshToken: "mock-refresh-token",
        user: {
          id: "admin-1",
          name: "Rasha Hamouda",
          email,
          avatarUrl: "https://picsum.photos/seed/adminavatar/96/96",
        },
      });
    }
    return api.post<AdminSession>(endpoints.auth.login, { email, password });
  },
};

export const productService = {
  list: () => (isMockMode() ? delay(mockProducts) : api.get<Product[]>(endpoints.products.list)),
  create: (p: Product) => (isMockMode() ? delay(p) : api.post<Product>(endpoints.products.create, p)),
  update: (p: Product) =>
    isMockMode() ? delay(p) : api.put<Product>(endpoints.products.update(p.id), p),
  remove: (id: string) =>
    isMockMode() ? delay(undefined) : api.delete<void>(endpoints.products.remove(id)),
};

export const categoryService = {
  list: () => (isMockMode() ? delay(mockCategories) : api.get<Category[]>(endpoints.categories.list)),
  create: (c: Category) =>
    isMockMode() ? delay(c) : api.post<Category>(endpoints.categories.create, c),
  update: (c: Category) =>
    isMockMode() ? delay(c) : api.put<Category>(endpoints.categories.update(c.id), c),
  remove: (id: string) =>
    isMockMode() ? delay(undefined) : api.delete<void>(endpoints.categories.remove(id)),
};

export const subcategoryService = {
  list: () =>
    isMockMode() ? delay(mockSubcategories) : api.get<Subcategory[]>(endpoints.subcategories.list),
  create: (s: Subcategory) =>
    isMockMode() ? delay(s) : api.post<Subcategory>(endpoints.subcategories.create, s),
  update: (s: Subcategory) =>
    isMockMode() ? delay(s) : api.put<Subcategory>(endpoints.subcategories.update(s.id), s),
  remove: (id: string) =>
    isMockMode() ? delay(undefined) : api.delete<void>(endpoints.subcategories.remove(id)),
};

export const orderService = {
  list: () => (isMockMode() ? delay(mockOrders) : api.get<Order[]>(endpoints.orders.list)),
  updateStatus: (id: string, status: OrderStatus) =>
    isMockMode()
      ? delay(undefined)
      : api.patch<void>(endpoints.orders.updateStatus(id), { status }),
};

export const returnService = {
  list: () => (isMockMode() ? delay(mockReturns) : api.get<ReturnRequest[]>(endpoints.returns.list)),
  updateStatus: (id: string, status: ReturnStatus) =>
    isMockMode()
      ? delay(undefined)
      : api.patch<void>(endpoints.returns.updateStatus(id), { status }),
};

export const reviewService = {
  list: () => (isMockMode() ? delay(mockReviews) : api.get<ProductReview[]>(endpoints.reviews.list)),
  remove: (id: string) =>
    isMockMode() ? delay(undefined) : api.delete<void>(endpoints.reviews.remove(id)),
};

export const userService = {
  list: () => (isMockMode() ? delay(mockUsers) : api.get<AppUser[]>(endpoints.users.list)),
  detail: (id: string) =>
    isMockMode()
      ? delay(mockUsers.find((u) => u.id === id))
      : api.get<AppUser>(endpoints.users.detail(id)),
};

export const paymentMethodService = {
  list: () =>
    isMockMode()
      ? delay(mockPaymentMethods)
      : api.get<PaymentMethod[]>(endpoints.paymentMethods.list),
};