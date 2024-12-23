import nextJsConfig from "@/next.config";

const getPublicCollectionData = async (collectionId: number) => {
  const res = await fetch(`${nextJsConfig.basePath}/api/v1/public/collections/` + collectionId);

  if (res.status === 400)
    return { response: "Collection not found.", status: 400 };

  const data = await res.json();

  return data;
};

export default getPublicCollectionData;
