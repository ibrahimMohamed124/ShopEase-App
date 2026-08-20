const DEFAULT_BASE_URL =
  (import.meta.env["VITE_API_BASE_URL"] as string | undefined) ?? "http://192.168.8.106:3000";

const BASE_URL_KEY = "shopease.apiBaseUrl";
const USE_MOCK_KEY = "shopease.useMockData";

export function getApiBaseUrl(): string {
  if (typeof window === "undefined") return DEFAULT_BASE_URL;
  return window.localStorage.getItem(BASE_URL_KEY) ?? DEFAULT_BASE_URL;
}

export function setApiBaseUrl(url: string) {
  if (typeof window !== "undefined") window.localStorage.setItem(BASE_URL_KEY, url);
}

export function getDefaultApiBaseUrl() {
  return DEFAULT_BASE_URL;
}

/** When true (the default) the service layer serves local sample data. */
export function isMockMode(): boolean {
  if (typeof window === "undefined") return true;
  return window.localStorage.getItem(USE_MOCK_KEY) !== "false";
}

export function setMockMode(enabled: boolean) {
  if (typeof window !== "undefined")
    window.localStorage.setItem(USE_MOCK_KEY, enabled ? "true" : "false");
}

/**
 * Every backend path the admin panel uses lives here so the contract is easy
 * to adjust when the real API differs.
 */
export const endpoints = {
  auth: {
    login: "/auth/login",
    register: "/auth/register",
    forgotPassword: "/auth/forgot-password",
    refresh: "/auth/refresh",
  },
  products: {
    list: "/products",
    featured: "/products/featured",
    create: "/products",
    detail: (id: string) => `/products/${id}`,
    update: (id: string) => `/products/${id}`,
    remove: (id: string) => `/products/${id}`,
  },
  categories: {
    list: "/categories",
    create: "/categories",
    update: (id: string) => `/categories/${id}`,
    remove: (id: string) => `/categories/${id}`,
  },
  subcategories: {
    list: "/subcategories",
    create: "/subcategories",
    update: (id: string) => `/subcategories/${id}`,
    remove: (id: string) => `/subcategories/${id}`,
  },
  orders: {
    list: "/orders",
    detail: (id: string) => `/orders/${id}`,
    updateStatus: (id: string) => `/orders/${id}/status`,
  },
  returns: {
    list: "/returns",
    updateStatus: (id: string) => `/returns/${id}/status`,
  },
  reviews: {
    list: "/reviews",
    remove: (id: string) => `/reviews/${id}`,
  },
  users: {
    list: "/users",
    me: "/users/me",
    detail: (id: string) => `/users/${id}`,
    avatar: "/users/me/avatar",
    shippingAddress: "/users/me/shipping-address",
  },
  paymentMethods: { list: "/payment-methods" },
} as const;