import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalFooter,
  ModalBody,
  ModalCloseButton,
  Button,
  useDisclosure,
} from "@chakra-ui/react";

import { mhABI } from "@/information/constants";

import { usePrepareContractWrite, useContractWrite } from "wagmi";

export default function YesModal({ mhAddress }) {
  const { isOpen, onOpen, onClose } = useDisclosure();

  return (
    <>
      <Button bgColor="green.400" onClick={onOpen}>
        Yes
      </Button>
      <Modal isOpen={isOpen} onClose={onClose}>
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>Modal 2</ModalHeader>
          <ModalCloseButton />
          <ModalBody>
            {/* Your modal content for Modal 2 */}
            This is Modal 2 content.
          </ModalBody>
          <ModalFooter>
            <Button colorScheme="blue" mr={3} onClick={onClose}>
              Close
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
}
