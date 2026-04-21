import { createBrowserRouter } from "react-router";
import Login from "./pages/Login";
import ClientLayout from "./layouts/ClientLayout";
import AdminLayout from "./layouts/AdminLayout";
import ClientHome from "./pages/client/Home";
import ClientFinances from "./pages/client/Finances";
import AdminDashboard from "./pages/admin/Dashboard";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Login,
  },
  {
    path: "/client",
    Component: ClientLayout,
    children: [
      { index: true, Component: ClientHome },
      { path: "finances", Component: ClientFinances },
    ],
  },
  {
    path: "/admin",
    Component: AdminLayout,
    children: [
      { index: true, Component: AdminDashboard },
    ],
  },
]);
