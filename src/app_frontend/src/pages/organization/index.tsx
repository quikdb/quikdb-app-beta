import OrgSidebar from "@/components/OrgSidebar";
import { Outlet } from "react-router-dom";

const Orgs = () => {
  return (
    <div className="max-md:px-4 max-md:py-3 min-h-screen">
      <OrgSidebar />
      <div className="ml-[20%] max-lg:m-0">
        <Outlet />
      </div>
    </div>
  );
};

export default Orgs;