import { Link, useNavigate, useRouterState } from "@tanstack/react-router";
import {
  CreditCard,
  LayoutDashboard,
  LogOut,
  Package,
  Search,
  Settings,
  ShoppingBag,
  Star,
  Tags,
  Undo2,
  Users,
} from "lucide-react";
import { useEffect, type ReactNode } from "react";
import { cn } from "@/lib/utils";
import { useAdminStore } from "@/lib/store";

const nav = [
  { to: "/", label: "Dashboard", icon: LayoutDashboard },
  { to: "/products", label: "Products", icon: Package },
  { to: "/categories", label: "Categories", icon: Tags },
  { to: "/orders", label: "Orders", icon: ShoppingBag },
  { to: "/returns", label: "Returns", icon: Undo2 },
  { to: "/reviews", label: "Reviews", icon: Star },
  { to: "/users", label: "Users", icon: Users },
  { to: "/payments", label: "Payment methods", icon: CreditCard },
  { to: "/settings", label: "Settings", icon: Settings },
] as const;

export function AdminShell({
  title,
  subtitle,
  actions,
  children,
}: {
  title: string;
  subtitle?: string;
  actions?: ReactNode;
  children: ReactNode;
}) {
  const { session, ready, logout } = useAdminStore();
  const navigate = useNavigate();
  const pathname = useRouterState({ select: (s) => s.location.pathname });

  useEffect(() => {
    if (ready && !session) void navigate({ to: "/login", replace: true });
  }, [ready, session, navigate]);

  if (!ready || !session) {
    return <div className="min-h-screen bg-background" />;
  }

  return (
    <div className="flex min-h-screen min-w-[1280px] bg-background">
      <aside className="fixed inset-y-0 left-0 flex w-60 flex-col border-r border-border bg-card">
        <div className="flex items-center gap-3 px-6 py-7">
          <div className="flex size-9 items-center justify-center rounded-xl bg-primary text-primary-foreground">
            <ShoppingBag className="size-5" />
          </div>
          <div>
            <p className="text-sm font-bold leading-tight">ShopEase</p>
            <p className="text-xs text-muted-foreground">Admin panel</p>
          </div>
        </div>
        <nav className="flex-1 space-y-1 px-3">
          {nav.map((item) => {
            const active = item.to === "/" ? pathname === "/" : pathname.startsWith(item.to);
            const Icon = item.icon;
            return (
              <Link
                key={item.to}
                to={item.to}
                className={cn(
                  "flex items-center gap-3 rounded-[14px] px-3 py-2.5 text-sm font-medium transition-colors",
                  active
                    ? "bg-primary/12 font-semibold text-primary"
                    : "text-muted-foreground hover:bg-muted hover:text-foreground",
                )}
              >
                <Icon className="size-4.5" />
                {item.label}
              </Link>
            );
          })}
        </nav>
        <button
          onClick={() => {
            logout();
            void navigate({ to: "/login", replace: true });
          }}
          className="mx-3 mb-6 flex items-center gap-3 rounded-[14px] px-3 py-2.5 text-sm font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
        >
          <LogOut className="size-4.5" />
          Sign out
        </button>
      </aside>

      <div className="ml-60 flex-1">
        <header className="flex items-center justify-between gap-8 border-b border-border bg-card px-8 py-5">
          <div>
            <h1 className="text-xl font-bold tracking-tight">{title}</h1>
            {subtitle ? <p className="mt-0.5 text-sm text-muted-foreground">{subtitle}</p> : null}
          </div>
          <div className="flex items-center gap-5">
            <div className="relative w-72">
              <Search className="absolute left-4 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <input className="se-input pl-11" placeholder="Search ShopEase…" />
            </div>
            {actions}
            <div className="flex items-center gap-3 border-l border-border pl-5">
              <img
                src={session.user.avatarUrl ?? "https://picsum.photos/seed/adminavatar/96/96"}
                alt={session.user.name}
                className="size-9 rounded-full object-cover"
              />
              <div className="leading-tight">
                <p className="text-sm font-semibold">{session.user.name}</p>
                <p className="text-xs text-muted-foreground">{session.user.email}</p>
              </div>
            </div>
          </div>
        </header>
        <main className="p-8">{children}</main>
      </div>
    </div>
  );
}