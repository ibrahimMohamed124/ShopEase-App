import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { AdminShell } from "@/components/admin/AdminShell";
import { Card, CardHeader, Chip, Field } from "@/components/admin/ui";
import {
  getApiBaseUrl,
  getDefaultApiBaseUrl,
  isMockMode,
  setApiBaseUrl,
  setMockMode,
} from "@/lib/api-config";
import { useAdminStore } from "@/lib/store";

export const Route = createFileRoute("/settings")({
  head: () => ({
    meta: [
      { title: "Settings — ShopEase Admin" },
      { name: "description", content: "Configure the ShopEase admin API base URL and data source." },
      { property: "og:title", content: "Settings — ShopEase Admin" },
      {
        property: "og:description",
        content: "Configure the ShopEase admin API base URL and data source.",
      },
    ],
  }),
  component: SettingsPage,
});

function SettingsPage() {
  const { session } = useAdminStore();
  const [baseUrl, setBaseUrl] = useState(() => getApiBaseUrl());
  const [mock, setMock] = useState(() => isMockMode());
  const [saved, setSaved] = useState(false);

  const save = () => {
    setApiBaseUrl(baseUrl.trim().replace(/\/$/, ""));
    setMockMode(mock);
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  return (
    <AdminShell title="Settings" subtitle="Backend connection for this admin workstation">
      <div className="grid max-w-4xl gap-6">
        <Card>
          <CardHeader
            title="API connection"
            subtitle="The REST backend shared with the ShopEase mobile app"
          />
          <div className="space-y-5 px-6 py-6">
            <Field label="API base URL">
              <input
                className="se-input"
                value={baseUrl}
                onChange={(e) => setBaseUrl(e.target.value)}
                placeholder={getDefaultApiBaseUrl()}
              />
            </Field>
            <p className="text-xs text-muted-foreground">
              Default from environment: {getDefaultApiBaseUrl()}. Requests are sent with an
              Authorization Bearer token and retried once after a refresh on 401.
            </p>

            <div className="flex items-center justify-between rounded-[14px] border border-border bg-muted/60 px-5 py-4">
              <div>
                <p className="text-sm font-semibold">Use sample data</p>
                <p className="mt-1 text-xs text-muted-foreground">
                  Keep this on to browse the dashboard without a live backend.
                </p>
              </div>
              <button
                type="button"
                role="switch"
                aria-checked={mock}
                onClick={() => setMock((v) => !v)}
                className={`relative h-7 w-12 rounded-full transition-colors ${mock ? "bg-primary" : "bg-border"}`}
              >
                <span
                  className={`absolute top-1 size-5 rounded-full bg-card transition-all ${mock ? "left-6" : "left-1"}`}
                />
              </button>
            </div>

            <div className="flex items-center gap-3">
              <button className="se-btn se-btn-primary" onClick={save}>
                Save settings
              </button>
              {saved ? <Chip tone="success">Saved</Chip> : null}
              <Chip tone={mock ? "muted" : "secondary"}>
                {mock ? "Sample data mode" : "Live API mode"}
              </Chip>
            </div>
          </div>
        </Card>

        <Card>
          <CardHeader title="Signed in admin" subtitle="Session stored locally on this machine" />
          <div className="grid grid-cols-2 gap-6 px-6 py-6 text-sm">
            <div>
              <p className="text-xs font-semibold text-muted-foreground">Name</p>
              <p className="mt-1 font-medium">{session?.user.name}</p>
            </div>
            <div>
              <p className="text-xs font-semibold text-muted-foreground">Email</p>
              <p className="mt-1 font-medium">{session?.user.email}</p>
            </div>
          </div>
        </Card>
      </div>
    </AdminShell>
  );
}