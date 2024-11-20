import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";

const Documentation = () => {
  // Data for the cards
  const cards = [
    { title: "Quick Start", description: "A quick guide to help you start using the app efficiently." },
    { title: "User Guide", description: "Comprehensive instructions to make the most out of each feature." },
    { title: "Troubleshooting", description: "Solutions to common issues you may encounter." },
    { title: "FAQ", description: "Answers to frequently asked questions about QuikDB." },
    { title: "Plugins", description: "Enhance your experience with additional features." },
    { title: "Glossary", description: "Definitions of terms and concepts used in QuikDB." },
    { title: "Contact Support", description: "Need help? Reach out to our support team." },
    { title: "Internet Identity", description: "Learn about secure access and identity management." },
  ];

  return (
    <div className="mt-10 px-4 lg:px-8">
      {/* Header Section */}
      <div className="flex flex-col gap-1">
        <p className="font-satoshi_medium text-3xl">QuikDB Documentation</p>
        <p className="font-satoshi_light text-base text-gray-400">
          Unlock API Access with Personal Tokens
        </p>
      </div>

      {/* Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 mt-7">
        {cards.map((card, index) => (
          <Card key={index} className="bg-blackoff border border-gray-700">
            <CardHeader>
              <CardTitle className="text-white">{card.title}</CardTitle>
              <CardDescription className="text-gray-400">
                {card.description}
              </CardDescription>
            </CardHeader>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default Documentation;
