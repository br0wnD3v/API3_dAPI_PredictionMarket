import { useAccount } from "wagmi";
import { useEffect, useState } from "react";
import { ApolloClient, InMemoryCache, gql } from "@apollo/client";
import { graphEndpoint } from "@/constants/info";

import { toast } from "react-toastify";

import DashboardLanding from "./DashboardLanding";

export default function DashboardGetInformation() {
  const { address } = useAccount();

  const [dataFetched, setDataFetched] = useState(null);

  const queryFinal = `query AccountInformation\n{\n  handlerProgresses(\n    orderBy: predictionId\n    where: {trader: "${address}"}\n    orderDirection: asc\n  ) {\n    predictionId\n    marketHandler\n    trader\n    amountNo\n    amountYes\n  }\n}`;

  const client = new ApolloClient({
    uri: graphEndpoint,
    cache: new InMemoryCache(),
  });

  useEffect(() => {
    async function execute() {
      var { data } = await client.query({
        query: gql`
          ${queryFinal}
        `,
      });
      const finalArray = data.handlerProgresses;
      setDataFetched(finalArray);
    }
    toast.info("Sit back and relax while we fetch recent details :) ...");
    execute();
  }, []);

  return <>{dataFetched ? <DashboardLanding data={dataFetched} /> : null}</>;
}
