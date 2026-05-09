<?php

namespace App\DataFixtures;

use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;
use App\Entity\User;
use App\Entity\Message;
use App\Entity\Forum;
use Doctrine\Common\DataFixtures\DependentFixtureInterface;

class MessageFixtures extends Fixture implements DependentFixtureInterface
{
    private $faker;

    public function __construct()
    {
        $this->faker = Factory::create("fr_FR");
    }

    public function load(ObjectManager $manager): void
    {
        // On s'assure qu'au moins un message est créé pour CHAQUE forum (40 au total)
        for ($i = 0; $i < 40; $i++) {
            $message = new Message();
            $message->setTitre($this->faker->sentence(3));
            $message->setDatePoste($this->faker->dateTimeThisYear());
            $message->setContenu($this->faker->paragraph());
            $message->setUser($this->getReference('user' . mt_rand(0, 9), User::class));
            $message->setForum($this->getReference('forum_ref_' . $i, Forum::class));
            $manager->persist($message);
            $this->addReference('message_ref_' . $i, $message);
        }

        // On ajoute quelques réponses aléatoires pour rendre le forum vivant
        for ($i = 0; $i < 20; $i++) {
            $message = new Message();
            $message->setTitre('Re: ' . $this->faker->sentence(2));
            $message->setDatePoste($this->faker->dateTimeThisYear());
            $message->setContenu($this->faker->paragraph());
            $message->setUser($this->getReference('user' . mt_rand(0, 9), User::class));
            
            // On prend un message parent aléatoire parmi les 40 premiers
            $parent = $this->getReference('message_ref_' . mt_rand(0, 39), Message::class);
            $message->setParent($parent);
            $message->setForum($parent->getForum());
            
            $manager->persist($message);
        }

        $manager->flush();
    }

    public function getDependencies(): array
    {
        return [
            UserFixtures::class,
            ForumFixtures::class,
        ];
    }
}
