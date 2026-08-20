import { getApiBaseUrl, endpoints } from "./api-config";

const TOKEN_KEY = "shopease.token";
const REFRESH_KEY = "shopease.refreshToken";

export const tokenStore = {
  get: () => (typeof window === "undefined" ? null : localStorage.getItem(TOKEN_KEY)),
  getRefresh: () => (typeof window === "undefined" ? null : localStorage.getItem(REFRESH_KEY)),
  set: (token: string, refresh?: string) => {
    localStorage.setItem(TOKEN_KEY, token);
    if (refresh) localStorage.setItem(REFRESH_KEY, refresh);
  },
  clear: () => {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(REFRESH_KEY);
  },
};

export class ApiError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

type Method = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";

interface RequestOptions {
  method?: Method;
  body?: unknown;
  auth?: boolean;
  signal?: AbortSignal;
}

let refreshing: Promise<string | null> | null = null;

async function refreshToken(): Promise<string | null> {
  const refresh = tokenStore.getRefresh();
  if (!refresh) return null;
  try {
    const res = await fetch(`${getApiBaseUrl()}${endpoints.auth.refresh}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken: refresh }),
    });
    if (!res.ok) return null;
    const data = (await res.json()) as { token?: string; accessToken?: string };
    const token = data.token ?? data.accessToken ?? null;
    if (token) tokenStore.set(token, refresh);
    return token;
  } catch {
    return null;
  }
}

async function raw<T>(path: string, options: RequestOptions, token: string | null): Promise<T> {
  const headers: Record<string, string> = { Accept: "application/json" };
  if (options.body !== undefined) headers["Content-Type"] = "application/json";
  if (token) headers["Authorization"] = `Bearer ${token}`;

  const res = await fetch(`${getApiBaseUrl()}${path}`, {
    method: options.method ?? "GET",
    headers,
    ...(options.body !== undefined ? { body: JSON.stringify(options.body) } : {}),
    ...(options.signal ? { signal: options.signal } : {}),
  });

  if (!res.ok) {
    let message = res.statusText;
    try {
      const data = (await res.json()) as { message?: string };
      if (data?.message) message = data.message;
    } catch {
      /* ignore */
    }
    throw new ApiError(res.status, message);
  }
  if (res.status === 204) return undefined as T;
  return (await res.json()) as T;
}

/** Typed JSON client with bearer auth and a single refresh-on-401 retry. */
export async function apiRequest<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const useAuth = options.auth !== false;
  const token = useAuth ? tokenStore.get() : null;
  try {
    return await raw<T>(path, options, token);
  } catch (error) {
    if (error instanceof ApiError && error.status === 401 && useAuth) {
      refreshing = refreshing ?? refreshToken().finally(() => (refreshing = null));
      const fresh = await refreshing;
      if (fresh) return raw<T>(path, options, fresh);
      tokenStore.clear();
    }
    throw error;
  }
}

export const api = {
  get: <T,>(path: string) => apiRequest<T>(path),
  post: <T,>(path: string, body?: unknown) => apiRequest<T>(path, { method: "POST", ...(body !== undefined ? { body } : {}) }),
  put: <T,>(path: string, body?: unknown) => apiRequest<T>(path, { method: "PUT", ...(body !== undefined ? { body } : {}) }),
  patch: <T,>(path: string, body?: unknown) => apiRequest<T>(path, { method: "PATCH", ...(body !== undefined ? { body } : {}) }),
  delete: <T,>(path: string) => apiRequest<T>(path, { method: "DELETE" }),
};