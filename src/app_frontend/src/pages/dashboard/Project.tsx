import { useParams } from 'react-router-dom';

function Project() {
  const { projectId } = useParams();

  return (
    <div>
      <h1>Project Details</h1>
      <p>Project ID: {projectId}</p>
      {/* Add more project details here */}
    </div>
  );
}

export default Project;