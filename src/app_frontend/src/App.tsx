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
import Signup from "./pages/onboarding/signup";
import Login from "./pages/onboarding/login";
import Project from "./pages/dashboard/Project";
import AddCollaborators from "./pages/dashboard/AddCollaborators";

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
      path: "organizations",
      element: <Orgs />,
      children: [
        {
          path: "",
          element: <Organizations />,
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
        {
          path: ":projectId",
          element: <Project />,
        },
        {
          path: "add_collaborators",
          element: <AddCollaborators />,
        }
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
