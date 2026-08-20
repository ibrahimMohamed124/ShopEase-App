import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import { tokenStore } from "./api-client";
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
import { authService, orderService, productService, returnService, reviewService } from "./services";
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

interface AdminStore {
  session: AdminSession | null;
  ready: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  products: Product[];
  categories: Category[];
  subcategories: Subcategory[];
  orders: Order[];
  returns: ReturnRequest[];
  reviews: ProductReview[];
  users: AppUser[];
  paymentMethods: PaymentMethod[];
  saveProduct: (product: Product) => void;
  deleteProduct: (id: string) => void;
  saveCategory: (category: Category) => void;
  deleteCategory: (id: string) => void;
  saveSubcategory: (sub: Subcategory) => void;
  deleteSubcategory: (id: string) => void;
  setOrderStatus: (id: string, status: OrderStatus) => void;
  setReturnStatus: (id: string, status: ReturnStatus) => void;
  deleteReview: (id: string) => void;
}

const StoreContext = createContext<AdminStore | null>(null);

const SESSION_KEY = "shopease.session";

export function AdminStoreProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<AdminSession | null>(null);
  const [ready, setReady] = useState(false);
  const [products, setProducts] = useState<Product[]>(mockProducts);
  const [categories, setCategories] = useState<Category[]>(mockCategories);
  const [subcategories, setSubcategories] = useState<Subcategory[]>(mockSubcategories);
  const [orders, setOrders] = useState<Order[]>(mockOrders);
  const [returns, setReturns] = useState<ReturnRequest[]>(mockReturns);
  const [reviews, setReviews] = useState<ProductReview[]>(mockReviews);
  const [users] = useState<AppUser[]>(mockUsers);
  const [paymentMethods] = useState<PaymentMethod[]>(mockPaymentMethods);

  useEffect(() => {
    const stored = localStorage.getItem(SESSION_KEY);
    if (stored && tokenStore.get()) {
      try {
        setSession(JSON.parse(stored) as AdminSession);
      } catch {
        localStorage.removeItem(SESSION_KEY);
      }
    }
    setReady(true);
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    const result = await authService.login(email, password);
    tokenStore.set(result.token, result.refreshToken);
    localStorage.setItem(SESSION_KEY, JSON.stringify(result));
    setSession(result);
  }, []);

  const logout = useCallback(() => {
    tokenStore.clear();
    localStorage.removeItem(SESSION_KEY);
    setSession(null);
  }, []);

  const recountCategories = (list: Product[]) =>
    setCategories((prev) =>
      prev.map((c) => ({ ...c, productCount: list.filter((p) => p.category === c.id).length })),
    );

  const value = useMemo<AdminStore>(
    () => ({
      session,
      ready,
      login,
      logout,
      products,
      categories,
      subcategories,
      orders,
      returns,
      reviews,
      users,
      paymentMethods,
      saveProduct: (product) => {
        setProducts((prev) => {
          const exists = prev.some((p) => p.id === product.id);
          const next = exists
            ? prev.map((p) => (p.id === product.id ? product : p))
            : [product, ...prev];
          recountCategories(next);
          return next;
        });
        void (products.some((p) => p.id === product.id)
          ? productService.update(product)
          : productService.create(product)
        ).catch(() => undefined);
      },
      deleteProduct: (id) => {
        setProducts((prev) => {
          const next = prev.filter((p) => p.id !== id);
          recountCategories(next);
          return next;
        });
        void productService.remove(id).catch(() => undefined);
      },
      saveCategory: (category) =>
        setCategories((prev) =>
          prev.some((c) => c.id === category.id)
            ? prev.map((c) => (c.id === category.id ? category : c))
            : [...prev, category],
        ),
      deleteCategory: (id) => {
        setCategories((prev) => prev.filter((c) => c.id !== id));
        setSubcategories((prev) => prev.filter((s) => s.categoryId !== id));
      },
      saveSubcategory: (sub) => {
        setSubcategories((prev) =>
          prev.some((s) => s.id === sub.id)
            ? prev.map((s) => (s.id === sub.id ? sub : s))
            : [...prev, sub],
        );
        setCategories((prev) =>
          prev.map((c) =>
            c.id === sub.categoryId && !c.subcategories.includes(sub.id)
              ? { ...c, subcategories: [...c.subcategories, sub.id] }
              : c,
          ),
        );
      },
      deleteSubcategory: (id) => {
        setSubcategories((prev) => prev.filter((s) => s.id !== id));
        setCategories((prev) =>
          prev.map((c) => ({ ...c, subcategories: c.subcategories.filter((s) => s !== id) })),
        );
      },
      setOrderStatus: (id, status) => {
        setOrders((prev) =>
          prev.map((o) =>
            o.id === id
              ? {
                  ...o,
                  status,
                  ...(status === "delivered" ? { deliveredDate: new Date().toISOString() } : {}),
                  history: [...(o.history ?? []), { status, date: new Date().toISOString() }],
                }
              : o,
          ),
        );
        void orderService.updateStatus(id, status).catch(() => undefined);
      },
      setReturnStatus: (id, status) => {
        setReturns((prev) => prev.map((r) => (r.id === id ? { ...r, status } : r)));
        void returnService.updateStatus(id, status).catch(() => undefined);
      },
      deleteReview: (id) => {
        setReviews((prev) => prev.filter((r) => r.id !== id));
        void reviewService.remove(id).catch(() => undefined);
      },
    }),
    [
      session,
      ready,
      login,
      logout,
      products,
      categories,
      subcategories,
      orders,
      returns,
      reviews,
      users,
      paymentMethods,
    ],
  );

  return <StoreContext.Provider value={value}>{children}</StoreContext.Provider>;
}

export function useAdminStore() {
  const ctx = useContext(StoreContext);
  if (!ctx) throw new Error("useAdminStore must be used inside AdminStoreProvider");
  return ctx;
}