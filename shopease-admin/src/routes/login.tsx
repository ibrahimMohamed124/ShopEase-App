import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { ShoppingBag } from "lucide-react";
import { useEffect, useState } from "react";
import { Field } from "@/components/admin/ui";
import { useAdminStore } from "@/lib/store";

export const Route = createFileRoute("/login")({
  head: () => ({
    meta: [
      { title: "Sign in — ShopEase Admin" },
      { name: "description", content: "Sign in to the ShopEase admin dashboard." },
      { property: "og:title", content: "Sign in — ShopEase Admin" },
      { property: "og:description", content: "Sign in to the ShopEase admin dashboard." },
    ],
  }),
  component: LoginPage,
});

function LoginPage() {
  const { login, session, ready } = useAdminStore();
  const navigate = useNavigate();
  const [email, setEmail] = useState("admin@shopease.com");
  const [password, setPassword] = useState("password");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (ready && session) void navigate({ to: "/", replace: true });
  }, [ready, session, navigate]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      await login(email, password);
      await navigate({ to: "/", replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to sign in");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-6">
      <div className="w-full max-w-md">
        <div className="mb-8 flex flex-col items-center text-center">
          <div className="flex size-12 items-center justify-center rounded-2xl bg-primary text-primary-foreground">
            <ShoppingBag className="size-6" />
          </div>
          <h1 className="mt-4 text-2xl font-bold tracking-tight">ShopEase Admin</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Sign in to manage products, orders and customers.
          </p>
        </div>
        <form onSubmit={handleSubmit} className="se-card space-y-5 p-8">
          <Field label="Email">
            <input
              className="se-input"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@shopease.com"
              required
            />
          </Field>
          <Field label="Password">
            <input
              className="se-input"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              required
            />
          </Field>
          {error ? <p className="text-sm font-medium text-destructive">{error}</p> : null}
          <button className="se-btn se-btn-primary w-full" disabled={loading}>
            {loading ? "Signing in…" : "Sign in"}
          </button>
          <p className="text-center text-xs text-muted-foreground">
            Sample mode is on — any email and password works.
          </p>
        </form>
      </div>
    </div>
  );
}