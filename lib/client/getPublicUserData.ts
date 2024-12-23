import { toast } from "react-hot-toast";
import nextJsConfig from "@/next.config";

export default async function getPublicUserData(id: number | string) {
  const response = await fetch(`${nextJsConfig.basePath}/api/v1/public/users/${id}`);

  const data = await response.json();

  if (!response.ok) toast.error(data.response);

  return data.response;
}
