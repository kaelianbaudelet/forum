<?php

namespace App\Entity;

use App\Repository\BadgeRepository;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\ApiFilter;
use ApiPlatform\Doctrine\Orm\Filter\OrderFilter;
use Symfony\Component\Serializer\Annotation\Groups;
use Symfony\Component\Validator\Constraints as Assert;

#[ApiResource(
    normalizationContext: ['groups' => ['badge:read']],
    denormalizationContext: ['groups' => ['badge:write']],
    order: ['nom' => 'ASC'],
    operations: [
        new \ApiPlatform\Metadata\GetCollection(),
        new \ApiPlatform\Metadata\Post(),
        new \ApiPlatform\Metadata\Get(),
        new \ApiPlatform\Metadata\Put(),
        new \ApiPlatform\Metadata\Patch(),
        new \ApiPlatform\Metadata\Delete(),
    ]
)]
#[ApiFilter(OrderFilter::class, properties: ['nom'])]
#[ORM\Entity(repositoryClass: BadgeRepository::class)]
class Badge
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['badge:read'])]
    private ?int $id = null;

    #[ORM\Column(length: 255)]
    #[Groups(['badge:read', 'badge:write'])]
    #[Assert\NotBlank(message: "Le nom du badge est obligatoire.")]
    private ?string $nom = null;

    #[ORM\Column(type: Types::TEXT)]
    #[Groups(['badge:read', 'badge:write'])]
    #[Assert\NotBlank(message: "La description du badge est obligatoire.")]
    private ?string $description = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getNom(): ?string
    {
        return $this->nom;
    }

    public function setNom(string $nom): static
    {
        $this->nom = $nom;

        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(string $description): static
    {
        $this->description = $description;

        return $this;
    }
}
