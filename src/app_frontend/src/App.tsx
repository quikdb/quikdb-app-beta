import "./index.css";
import { Toaster } from "react-hot-toast";
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
// import { app_backend } from 'declarations/app_backend';
import Onboarding from './pages/onboarding';
import Organizations from "./pages/organization/Organizations";
import Orgs from "./pages/organization";
import Dashboard from "./pages/dasboard/Dashboard";
import Dash from "./pages/dasboard";
import Projects from "./pages/dasboard/Projects";
import Documentation from "./pages/organization/Documentation";
import Overview from "./pages/organization/Overview";
import NewOrganization from "./pages/organization/NewOrganization";

function App() {
  const router = createBrowserRouter([
    {
      path: "/",
      element: <Onboarding />,
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
          path: "create-organization",
          element: <NewOrganization />,
        },
        {
          path: "documentation",
          element: <Documentation />,
        },
        // {
        //   path: "new-record",
        //   element: <NewRecord />,
        // },
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
      ],
    },
    {
      path: "*",
      element: <NoMatch />,
    },
  ]);

  return (
    <div className="bg-blacko text-white h-screen font-satoshi_regular">
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
