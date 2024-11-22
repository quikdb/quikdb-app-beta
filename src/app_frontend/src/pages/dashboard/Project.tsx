// import { useParams } from 'react-router-dom';

import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from "@/components/ui/tabs"
import Groups from "./Groups";

function Project() {
  // const { projectId } = useParams();

  return (
    <div className='mt-10'>
      <p className="mb-7 text-base">Project / <span className="text-[#72F5DD]">UrbanLifeSuite</span></p>
      <p>UrbanLifeSuite</p>
      {/* Add more project details here */}
      <Tabs defaultValue="groups" className="mt-5">
        <TabsList className="grid w-1/3 grid-cols-3 bg-transparent text-gray-400 font-satoshi_medium border-none border-b border-b-[#242527] gap-">
          <TabsTrigger value="groups">Groups</TabsTrigger>
          <TabsTrigger value="collaborators">Project Collaborators</TabsTrigger>
          <TabsTrigger value="connect">Connect</TabsTrigger>
        </TabsList>
        <TabsContent value="groups" className="bg-[#151418] text-white">
          <Groups />
        </TabsContent>
        <TabsContent value="collaborators">
          <Groups />
        </TabsContent>
        <TabsContent value="connect">
          <Groups />
        </TabsContent>
      </Tabs>
    </div>
  );
}

export default Project;