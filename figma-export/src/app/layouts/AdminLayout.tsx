import { Outlet } from "react-router";

export default function AdminLayout() {
  return (
    <div className="min-h-screen bg-[#f5f6f8]">
      <Outlet />
    </div>
  );
}
