import { Box } from "@chakra-ui/react";
import RewardCard from "./RewardCard";

export default function RewardsLanding({ userData, concluded }) {
  return (
    <>
      <Box m={10} maxH="max-content" bgColor="#F0FFF0" borderRadius={10}>
        {concluded.map((item, index) => (
          <RewardCard key={index} data={userData[item]} />
        ))}
      </Box>
    </>
  );
}
