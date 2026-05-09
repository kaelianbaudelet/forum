<?php

namespace App\Entity;

use App\Repository\MessageRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Patch;
use ApiPlatform\Metadata\Delete;
use ApiPlatform\Metadata\Post;
use ApiPlatform\Metadata\Put;
use ApiPlatform\Metadata\ApiFilter;
use ApiPlatform\Doctrine\Orm\Filter\SearchFilter;
use ApiPlatform\Doctrine\Orm\Filter\ExistsFilter;
use ApiPlatform\Doctrine\Orm\Filter\OrderFilter;
use Symfony\Component\Serializer\Annotation\Groups;

#[ApiResource(paginationItemsPerPage: 10, operations: [
    new GetCollection(normalizationContext: ['groups' => 'message:list']),
    new Post(
        processor: \App\State\MessageStateProcessor::class,
        security: "is_granted('ROLE_USER')",
        normalizationContext: ['groups' => ['message:item']],
        denormalizationContext: ['groups' => ['message:write']]
    ),
    new Get(normalizationContext: ['groups' => 'message:item']),
    new Put(),
    new Patch(),
    new Delete(),
],)]
#[ApiFilter(SearchFilter::class, properties: ['user' => 'exact', 'forum' => 'exact', 'parent' => 'exact'])]
#[ApiFilter(ExistsFilter::class, properties: ['parent'])]
#[ApiFilter(OrderFilter::class, properties: ['id' => 'ASC', 'titre' => 'DESC'])]
#[ORM\Entity(repositoryClass: MessageRepository::class)]
class Message
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['message:list', 'message:item', 'user:item', 'forum:read'])]
    private ?int $id = null;

    #[ORM\Column(length: 50)]
    #[Groups(['message:list', 'message:item', 'user:item', 'forum:read', 'message:write'])]
    private ?string $titre = null;

    #[ORM\Column]
    #[Groups(['message:list', 'message:item', 'user:item', 'forum:read'])]
    private ?\DateTime $datePoste = null;

    #[ORM\Column(type: Types::TEXT)]
    #[Groups(['message:list', 'message:item', 'user:item', 'forum:read', 'message:write'])]
    private ?string $contenu = null;

    #[ORM\ManyToOne(inversedBy: 'messages')]
    #[ORM\JoinColumn(nullable: false)]
    #[Groups(['message:list', 'message:item', 'forum:read'])]
    private ?User $user = null;

    #[ORM\ManyToOne(targetEntity: self::class, inversedBy: 'replies')]
    #[ORM\JoinColumn(onDelete: 'SET NULL')]
    #[Groups(['message:list', 'message:item', 'message:write'])]
    private ?self $parent = null;

    /**
     * @var Collection<int, self>
     */
    #[ORM\OneToMany(targetEntity: self::class, mappedBy: 'parent')]
    #[Groups(['message:item', 'message:list'])]
    private Collection $replies;

    #[ORM\ManyToOne(targetEntity: Forum::class, inversedBy: 'messages')]
    #[ORM\JoinColumn(nullable: true)]
    #[Groups(['message:list', 'message:item', 'message:write'])]
    private ?Forum $forum = null;

    public function __construct()
    {
        $this->replies = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getTitre(): ?string
    {
        return $this->titre;
    }

    public function setTitre(string $titre): static
    {
        $this->titre = $titre;

        return $this;
    }

    public function getDatePoste(): ?\DateTime
    {
        return $this->datePoste;
    }

    public function setDatePoste(\DateTime $datePoste): static
    {
        $this->datePoste = $datePoste;

        return $this;
    }

    public function getContenu(): ?string
    {
        return $this->contenu;
    }

    public function setContenu(string $contenu): static
    {
        $this->contenu = $contenu;

        return $this;
    }

    public function getUser(): ?User
    {
        return $this->user;
    }

    public function setUser(?User $user): static
    {
        $this->user = $user;

        return $this;
    }

    public function getParent(): ?self
    {
        return $this->parent;
    }

    public function setParent(?self $parent): static
    {
        $this->parent = $parent;

        return $this;
    }

    public function getForum(): ?Forum
    {
        return $this->forum;
    }

    public function setForum(?Forum $forum): static
    {
        $this->forum = $forum;

        return $this;
    }

    /**
     * @return Collection<int, self>
     */
    public function getReplies(): Collection
    {
        return $this->replies;
    }

    public function addReply(self $reply): static
    {
        if (!$this->replies->contains($reply)) {
            $this->replies->add($reply);
            $reply->setParent($this);
        }

        return $this;
    }

    public function removeReply(self $reply): static
    {
        if ($this->replies->removeElement($reply)) {
            // set the owning side to null (unless already changed)
            if ($reply->getParent() === $this) {
                $reply->setParent(null);
            }
        }

        return $this;
    }
}
