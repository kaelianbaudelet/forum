<?php

namespace App\DataFixtures;

use App\Entity\Forum;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;

class ForumFixtures extends Fixture
{
    private $faker;

    // Catégories de forums liées à l'éducation
    private array $forumTitres = [
        'Mathématiques',
        'Sciences Physiques & SVT',
        'Langues Vivantes',
        'Lettres & Philosophie',
        'Histoire-Géo & SES',
        'Informatique & Technologie',
        'Orientation & Conseils',
        'Vie Scolaire & Entraide',
    ];

    // Sous-forums scolaires associés
    private array $sousForums = [
        'Mathématiques'              => ['Algèbre', 'Géométrie', 'Analyse', 'Probabilités & Stats'],
        'Sciences Physiques & SVT'   => ['Physique', 'Chimie', 'Biologie', 'Géologie'],
        'Langues Vivantes'           => ['Anglais', 'Espagnol', 'Allemand', 'Langues Anciennes'],
        'Lettres & Philosophie'      => ['Littérature', 'Grammaire & Orthographe', 'Philosophie', 'Théâtre'],
        'Histoire-Géo & SES'         => ['Histoire', 'Géographie', 'Économie', 'Sciences Politiques'],
        'Informatique & Technologie' => ['Programmation', 'Algorithmie', 'Robotique', 'Web Design'],
        'Orientation & Conseils'     => ['Parcoursup', 'Écoles d\'Ingénieurs', 'Écoles de Commerce', 'Métiers'],
        'Vie Scolaire & Entraide'    => ['Entraide aux Devoirs', 'Organisation & Méthode', 'Stress & Examens', 'Projets Scolaires'],
    ];

    public function __construct()
    {
        $this->faker = Factory::create('fr_FR');
    }

    public function load(ObjectManager $manager): void
    {
        $parentIndex = 0;
        $forumCount = 0;

        foreach ($this->forumTitres as $titre) {
            // Création du forum parent
            $forumParent = new Forum();
            $forumParent->setTitre($titre);
            $forumParent->setDescription($this->faker->paragraph(2));
            $manager->persist($forumParent);

            $this->addReference('forum_parent_' . $parentIndex, $forumParent);
            $this->addReference('forum_ref_' . $forumCount, $forumParent);
            $forumCount++;

            // Création des sous-forums rattachés
            $sousTitres = $this->sousForums[$titre];
            foreach ($sousTitres as $sousTitre) {
                $sousForum = new Forum();
                $sousForum->setTitre($sousTitre);
                $sousForum->setDescription($this->faker->paragraph(1));
                $sousForum->setParent($forumParent);
                $manager->persist($sousForum);

                $this->addReference('forum_ref_' . $forumCount, $sousForum);
                $forumCount++;
            }

            $parentIndex++;
        }

        $manager->flush();
    }
}
