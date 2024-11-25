import "./index.css";
import { Toaster } from "react-hot-toast";
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
// import { app_backend } from 'declarations/app_backend';
import Onboarding from './pages/onboarding';
import Organizations from "./pages/organization/Organizations";
import Orgs from "./pages/organization";
import Dashboard from "./pages/dashboard/Dashboard";
import Dash from "./pages/dashboard";
import Projects from "./pages/dashboard/Projects";
import Documentation from "./pages/organization/Documentation";
import Overview from "./pages/organization/Overview";
import NewOrganization from "./pages/organization/NewOrganization";
import Signup from "./pages/onboarding/signup";
import Login from "./pages/onboarding/login";
import Project from "./pages/dashboard/Project";
import AddCollaborators from "./pages/dashboard/AddCollaborators";
import Settings from "./pages/organization/Settings";
import ListOrganizations from "./pages/organization/ListOrganizations";
import UserMgt from "./pages/dashboard/UserMgt";
import UserInvite from "./pages/dashboard/UserInvite";
import UserProfile from "./pages/dashboard/UserProfile";
import Rewards from "./pages/dashboard/Rewards";
import Analytics from "./pages/dashboard/Analytics";
import ForgotPassword from "./pages/onboarding/forgot_password";
import AuthCode from "./pages/onboarding/authCode/AuthCode";

function App() {
  const router = createBrowserRouter([
    {
      path: "/",
      element: <Onboarding />,
    },
    {
      path: "/signup",
      element: <Signup />,
    },
    {
      path: "/login",
      element: <Login />,
    },
    {
      path: "/forgot_password",
      element: <ForgotPassword />,
    },
    {
      path: "/authCode",
      element: <AuthCode />,
    },
    {
      path: "organizations",
      element: <Orgs />,
      children: [
        {
          path: "",
          element: <Overview />,
        },
        {
          path: "organizations",
          element: <Organizations />,
        },
        {
          path: "list-organizations",
          element: <ListOrganizations />,
        },
        {
          path: "create-organization",
          element: <NewOrganization />,
        },
        {
          path: "documentation",
          element: <Documentation />,
        },

        {
          path: "settings",
          element: <Settings />,
        },
      ],
    },
    {
      path: "dashboard",
      element: <Dash />,
      children: [
        {
          path: "",
          element: <Dashboard />,
        },
        {
          path: "projects",
          element: <Projects />,
        },
        {
          path: ":projectId",
          element: <Project />,
        },
        {
          path: "add-collaborators",
          element: <AddCollaborators />,
        },
        {
          path: "user-mgt",
          element: <UserMgt />,
        },
        {
          path: "user-invite",
          element: <UserInvite />,
        },
        {
          path: "user-profile",
          element: <UserProfile />,
        },
        {
          path: "rewards",
          element: <Rewards />
        },
        {
          path: "analytics",
          element: <Analytics />
        }
      ],
    },
    {
      path: "*",
      element: <NoMatch />,
    },
  ]);

  return (
    <div className="bg-blacko text-white h-screen font-satoshi_regular text-base">
      <RouterProvider router={router} />
      <Toaster />
    </div>
  );
}

function NoMatch() {
  return (
    <div className="grid place-content-center min-h-screen max-md:text-xl text-3xl">
      <h2>404: Page Not Found</h2>
      <p>Uh oh! Wrong page 😞</p>
    </div>
  );
}

export default App;
