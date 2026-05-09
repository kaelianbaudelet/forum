<?php

namespace App\DataFixtures;

use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;
use App\Entity\User;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\String\Slugger\AsciiSlugger;

class UserFixtures extends Fixture
{
    private $faker;
    private $passwordHasher;

    public function __construct(UserPasswordHasherInterface $passwordHasher)
    {
        $this->faker = Factory::create("fr_FR");
        $this->passwordHasher = $passwordHasher;
    }

    public function load(ObjectManager $manager): void
    {
        $slugger = new AsciiSlugger();

        for ($i = 0; $i < 10; $i++) {
            $user = new User();
            $user->setNom($this->faker->lastName())
                ->setPrenom($this->faker->firstName())
                ->setEmail(strtolower($user->getPrenom()) . '.' . strtolower($user->getNom()) . '@' . $this->faker->freeEmailDomain())
                ->setPassword($this->passwordHasher->hashPassword($user, $slugger->slug(strtolower($user->getPrenom()))))
                ->setDateInscription($this->faker->dateTimeThisYear())
                ->setPhone($this->faker->phoneNumber());
            
            $this->addReference('user' . $i, $user);
            $manager->persist($user);
        }

        // Jules Bertrand
        $jules = new User();
        $jules->setNom('Bertrand')
            ->setPrenom('Jules')
            ->setEmail('test@demo.fr')
            ->setPassword($this->passwordHasher->hashPassword($jules, 'test'))
            ->setDateInscription(new \DateTime())
            ->setPhone('06' . $this->faker->numerify('########'));
        
        $this->addReference('user_demo', $jules);
        $manager->persist($jules);
        
        $manager->flush();
    }
}
