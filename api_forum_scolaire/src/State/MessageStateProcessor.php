<?php

namespace App\State;

use ApiPlatform\Metadata\HttpOperation;
use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\Message;
use App\Entity\User;
use App\Repository\UserRepository;
use Symfony\Bundle\SecurityBundle\Security;

class MessageStateProcessor implements ProcessorInterface
{
    public function __construct(
        private ProcessorInterface $persistProcessor,
        private Security $security,
        private UserRepository $userRepository
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): mixed
    {
        if ($data instanceof Message && $operation instanceof HttpOperation && $operation->getMethod() === 'POST') {
            $currentUser = $this->security->getUser();
            
            if ($currentUser === null) {
                throw new \RuntimeException("Utilisateur non authentifié. Veuillez vous reconnecter.");
            }

            // On récupère la vraie entité User depuis la base de données
            $user = $this->userRepository->findOneBy(['email' => $currentUser->getUserIdentifier()]);
            
            if (!$user instanceof User) {
                throw new \RuntimeException("Profil utilisateur introuvable (votre session est peut-être périmée suite à une remise à zéro de la base). Veuillez vous déconnecter et vous reconnecter.");
            }

            $data->setUser($user);
            
            // On définit ou force la date de publication côté serveur
            $data->setDatePoste(new \DateTime());
        }

        return $this->persistProcessor->process($data, $operation, $uriVariables, $context);
    }
}
