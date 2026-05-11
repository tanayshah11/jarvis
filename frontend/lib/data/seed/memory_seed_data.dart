// Synthetic memory seed data for testing the knowledge graph
// This creates a rich, interconnected graph of a typical SF tech person

class MemorySeedData {
  // ============================================
  // PEOPLE (Friends, Family, Colleagues)
  // ============================================
  static final List<Map<String, dynamic>> people = [
    // Close Friends
    {
      'nodeType': 'person',
      'name': 'Sarah Chen',
      'attributes': {
        'relationship': 'close friend',
        'how_met': 'college roommate at Berkeley',
        'occupation': 'Product Manager at Stripe',
        'birthday': 'March 15',
        'interests': ['hiking', 'wine tasting', 'photography'],
        'location': 'San Francisco, Marina District',
        'notes': 'Always down for spontaneous trips. Allergic to shellfish.',
      },
    },
    {
      'nodeType': 'person',
      'name': 'Marcus Johnson',
      'attributes': {
        'relationship': 'best friend',
        'how_met': 'high school',
        'occupation': 'Software Engineer at Google',
        'birthday': 'July 22',
        'interests': ['basketball', 'gaming', 'crypto'],
        'location': 'Mountain View',
        'notes': 'Known each other for 15 years. Lakers fan.',
      },
    },
    {
      'nodeType': 'person',
      'name': 'Emily Rodriguez',
      'attributes': {
        'relationship': 'friend',
        'how_met': 'yoga class',
        'occupation': 'UX Designer at Figma',
        'birthday': 'November 3',
        'interests': ['yoga', 'art', 'sustainable fashion'],
        'location': 'San Francisco, Mission District',
        'notes': 'Great at recommending restaurants.',
      },
    },
    {
      'nodeType': 'person',
      'name': 'Alex Kim',
      'attributes': {
        'relationship': 'friend',
        'how_met': 'previous job at Uber',
        'occupation': 'Founder at stealth startup',
        'birthday': 'January 8',
        'interests': ['startups', 'tennis', 'coffee'],
        'location': 'San Francisco, SOMA',
        'notes': 'Great for startup advice. Coffee snob.',
      },
    },
    {
      'nodeType': 'person',
      'name': 'Jessica Park',
      'attributes': {
        'relationship': 'friend',
        'how_met': 'through Sarah',
        'occupation': 'Investment Associate at a]16z',
        'birthday': 'September 12',
        'interests': ['venture capital', 'running', 'podcasts'],
        'location': 'San Francisco, Pacific Heights',
        'notes': 'Runs marathons. Good VC network.',
      },
    },
    // Family
    {
      'nodeType': 'person',
      'name': 'Mom',
      'attributes': {
        'relationship': 'mother',
        'real_name': 'Linda',
        'occupation': 'Retired teacher',
        'birthday': 'May 20',
        'location': 'Los Angeles',
        'notes': 'Calls every Sunday. Loves gardening.',
      },
    },
    {
      'nodeType': 'person',
      'name': 'Dad',
      'attributes': {
        'relationship': 'father',
        'real_name': 'Robert',
        'occupation': 'Retired engineer',
        'birthday': 'August 14',
        'location': 'Los Angeles',
        'notes': 'Golf on Saturdays. Prefers texts over calls.',
      },
    },
    {
      'nodeType': 'person',
      'name': 'Jamie',
      'attributes': {
        'relationship': 'younger sibling',
        'occupation': 'Medical resident at UCLA',
        'birthday': 'December 1',
        'location': 'Los Angeles',
        'notes': 'Super busy with residency. Night owl.',
      },
    },
    // Work Colleagues
    {
      'nodeType': 'person',
      'name': 'David Thompson',
      'attributes': {
        'relationship': 'manager',
        'occupation': 'Engineering Director',
        'company': 'Current Company',
        'notes': 'Great mentor. Prefers async communication.',
      },
    },
    {
      'nodeType': 'person',
      'name': 'Priya Sharma',
      'attributes': {
        'relationship': 'colleague',
        'occupation': 'Senior Engineer',
        'company': 'Current Company',
        'notes': 'Go-to for backend questions. Tea lover.',
      },
    },
    {
      'nodeType': 'person',
      'name': 'Mike Chen',
      'attributes': {
        'relationship': 'colleague',
        'occupation': 'Data Scientist',
        'company': 'Current Company',
        'notes': 'Sits next to me. Into board games.',
      },
    },
  ];

  // ============================================
  // PLACES (Restaurants, Bars, Venues)
  // ============================================
  static final List<Map<String, dynamic>> places = [
    // Favorite Restaurants
    {
      'nodeType': 'place',
      'name': 'Lazy Bear',
      'attributes': {
        'type': 'restaurant',
        'cuisine': 'Modern American',
        'neighborhood': 'Mission District',
        'city': 'San Francisco',
        'price_range': '\$\$\$\$',
        'rating': 5,
        'notes': 'Incredible tasting menu. Book 2 months ahead.',
        'last_visited': '2024-10-15',
      },
    },
    {
      'nodeType': 'place',
      'name': 'Tartine Manufactory',
      'attributes': {
        'type': 'restaurant',
        'cuisine': 'Bakery & Cafe',
        'neighborhood': 'Mission District',
        'city': 'San Francisco',
        'price_range': '\$\$',
        'rating': 5,
        'notes': 'Best morning buns. Go early to avoid line.',
        'favorite_dish': 'Morning Bun, Country Bread',
      },
    },
    {
      'nodeType': 'place',
      'name': 'House of Prime Rib',
      'attributes': {
        'type': 'restaurant',
        'cuisine': 'Steakhouse',
        'neighborhood': 'Nob Hill',
        'city': 'San Francisco',
        'price_range': '\$\$\$',
        'rating': 5,
        'notes': 'Classic SF. Get the King Cut.',
        'favorite_dish': 'Prime Rib King Cut',
      },
    },
    {
      'nodeType': 'place',
      'name': 'Burma Superstar',
      'attributes': {
        'type': 'restaurant',
        'cuisine': 'Burmese',
        'neighborhood': 'Inner Richmond',
        'city': 'San Francisco',
        'price_range': '\$\$',
        'rating': 4,
        'notes': 'Tea leaf salad is a must. Long waits.',
        'favorite_dish': 'Tea Leaf Salad',
      },
    },
    {
      'nodeType': 'place',
      'name': 'Kokkari Estiatorio',
      'attributes': {
        'type': 'restaurant',
        'cuisine': 'Greek',
        'neighborhood': 'Financial District',
        'city': 'San Francisco',
        'price_range': '\$\$\$',
        'rating': 5,
        'notes': 'Great for business dinners. Amazing lamb.',
        'favorite_dish': 'Moussaka, Grilled Lamb Chops',
      },
    },
    // Bars & Coffee
    {
      'nodeType': 'place',
      'name': 'Trick Dog',
      'attributes': {
        'type': 'bar',
        'category': 'Cocktail Bar',
        'neighborhood': 'Mission District',
        'city': 'San Francisco',
        'price_range': '\$\$\$',
        'rating': 5,
        'notes': 'Creative cocktails. Menu changes seasonally.',
      },
    },
    {
      'nodeType': 'place',
      'name': 'Sightglass Coffee',
      'attributes': {
        'type': 'coffee shop',
        'neighborhood': 'SOMA',
        'city': 'San Francisco',
        'price_range': '\$\$',
        'rating': 5,
        'notes': 'Best pour over in the city. Good wifi.',
        'favorite_order': 'Cortado',
      },
    },
    {
      'nodeType': 'place',
      'name': 'ABV',
      'attributes': {
        'type': 'bar',
        'category': 'Cocktail Bar',
        'neighborhood': 'Mission District',
        'city': 'San Francisco',
        'price_range': '\$\$\$',
        'rating': 4,
        'notes': 'Great happy hour. Outdoor seating.',
      },
    },
    // Gyms & Fitness
    {
      'nodeType': 'place',
      'name': 'Barry\'s Bootcamp',
      'attributes': {
        'type': 'gym',
        'category': 'Fitness Studio',
        'neighborhood': 'SOMA',
        'city': 'San Francisco',
        'notes': 'Go to the 6am class with Coach Lisa.',
        'membership': 'ClassPass',
      },
    },
    {
      'nodeType': 'place',
      'name': 'Dolores Park',
      'attributes': {
        'type': 'park',
        'neighborhood': 'Mission District',
        'city': 'San Francisco',
        'notes': 'Perfect for weekend picnics. Sunny side is best.',
      },
    },
    // Travel Destinations
    {
      'nodeType': 'place',
      'name': 'Tokyo',
      'attributes': {
        'type': 'city',
        'country': 'Japan',
        'visited': true,
        'visit_date': '2024-04',
        'favorite_spots': ['Shibuya', 'Tsukiji Market', 'Golden Gai'],
        'notes': 'Want to go back. Need to visit Kyoto next time.',
      },
    },
    {
      'nodeType': 'place',
      'name': 'Napa Valley',
      'attributes': {
        'type': 'region',
        'state': 'California',
        'notes': 'Love the wine trains. Favorite winery is Opus One.',
        'favorite_wineries': ['Opus One', 'Stag\'s Leap', 'Domaine Carneros'],
      },
    },
  ];

  // ============================================
  // EVENTS (Concerts, Trips, Dinners)
  // ============================================
  static final List<Map<String, dynamic>> events = [
    {
      'nodeType': 'event',
      'name': 'Outside Lands 2024',
      'attributes': {
        'type': 'music festival',
        'date': '2024-08-09',
        'location': 'Golden Gate Park',
        'attended_with': ['Sarah Chen', 'Marcus Johnson'],
        'highlights': ['Tyler the Creator', 'The Killers', 'Sturgill Simpson'],
        'notes': 'Amazing weather this year. VIP was worth it.',
      },
    },
    {
      'nodeType': 'event',
      'name': 'Japan Trip 2024',
      'attributes': {
        'type': 'travel',
        'dates': '2024-04-10 to 2024-04-22',
        'cities': ['Tokyo', 'Osaka', 'Kyoto'],
        'highlights': ['Cherry blossoms', 'Teamlab Borderless', 'Ramen in Osaka'],
        'traveled_with': ['Sarah Chen'],
        'budget_spent': '\$4500',
      },
    },
    {
      'nodeType': 'event',
      'name': 'Sarah\'s 30th Birthday',
      'attributes': {
        'type': 'celebration',
        'date': '2024-03-15',
        'location': 'Lazy Bear',
        'attendees': ['Marcus Johnson', 'Emily Rodriguez', 'Jessica Park'],
        'gift_given': 'Spa day at Kabuki Springs',
        'notes': 'Surprise party went perfectly.',
      },
    },
    {
      'nodeType': 'event',
      'name': 'Coldplay Concert',
      'attributes': {
        'type': 'concert',
        'date': '2023-09-20',
        'venue': 'Chase Center',
        'attended_with': ['Emily Rodriguez'],
        'notes': 'Light bracelets were magical. Got floor seats.',
      },
    },
    {
      'nodeType': 'event',
      'name': 'Company Offsite Lake Tahoe',
      'attributes': {
        'type': 'work event',
        'dates': '2024-06-15 to 2024-06-17',
        'location': 'Lake Tahoe',
        'highlights': ['Team building', 'Skiing', 'Bonfire'],
        'notes': 'Good bonding with the team.',
      },
    },
    {
      'nodeType': 'event',
      'name': 'Thanksgiving 2024',
      'attributes': {
        'type': 'holiday',
        'date': '2024-11-28',
        'location': 'Los Angeles, Parents house',
        'attendees': ['Mom', 'Dad', 'Jamie'],
        'notes': 'First time seeing Jamie in 6 months.',
      },
    },
  ];

  // ============================================
  // MUSIC (Artists, Songs, Genres)
  // ============================================
  static final List<Map<String, dynamic>> music = [
    {
      'nodeType': 'artist',
      'name': 'Tyler, The Creator',
      'attributes': {
        'genre': 'Hip-Hop/Alternative',
        'favorite_albums': ['IGOR', 'Flower Boy', 'CHROMAKOPIA'],
        'seen_live': true,
        'last_seen': 'Outside Lands 2024',
        'notes': 'Creative genius. Love the production.',
      },
    },
    {
      'nodeType': 'artist',
      'name': 'Coldplay',
      'attributes': {
        'genre': 'Alternative Rock',
        'favorite_songs': ['Yellow', 'Fix You', 'The Scientist'],
        'seen_live': true,
        'notes': 'Nostalgic. Great live shows.',
      },
    },
    {
      'nodeType': 'artist',
      'name': 'Fleetwood Mac',
      'attributes': {
        'genre': 'Classic Rock',
        'favorite_songs': ['Dreams', 'The Chain', 'Go Your Own Way'],
        'notes': 'Perfect for long drives.',
      },
    },
    {
      'nodeType': 'artist',
      'name': 'Kendrick Lamar',
      'attributes': {
        'genre': 'Hip-Hop',
        'favorite_albums': ['good kid, m.A.A.d city', 'DAMN.', 'Mr. Morale'],
        'seen_live': false,
        'notes': 'Best lyricist alive. Need to see live.',
      },
    },
    {
      'nodeType': 'artist',
      'name': 'Khruangbin',
      'attributes': {
        'genre': 'Psychedelic/Funk',
        'favorite_albums': ['Con Todo El Mundo', 'Mordechai'],
        'notes': 'Perfect background music. Chill vibes.',
      },
    },
    {
      'nodeType': 'genre',
      'name': 'Lo-Fi Hip Hop',
      'attributes': {
        'use_case': 'Work focus music',
        'favorite_playlists': ['lofi beats', 'Chillhop Essentials'],
        'notes': 'Essential for coding sessions.',
      },
    },
  ];

  // ============================================
  // PREFERENCES (Likes & Dislikes)
  // ============================================
  static final List<Map<String, dynamic>> preferences = [
    // Food Preferences
    {
      'nodeType': 'preference',
      'name': 'Loves Sushi',
      'attributes': {
        'category': 'food',
        'type': 'like',
        'specifics': ['Omakase', 'Fatty Tuna', 'Uni'],
        'notes': 'Will travel for good sushi.',
      },
    },
    {
      'nodeType': 'preference',
      'name': 'Coffee Snob',
      'attributes': {
        'category': 'beverage',
        'type': 'like',
        'specifics': ['Pour over', 'Single origin', 'Light roast'],
        'dislikes': ['Starbucks', 'Dark roast', 'Flavored coffee'],
      },
    },
    {
      'nodeType': 'preference',
      'name': 'Dislikes Cilantro',
      'attributes': {
        'category': 'food',
        'type': 'dislike',
        'notes': 'Tastes like soap. Genetic thing.',
      },
    },
    {
      'nodeType': 'preference',
      'name': 'Wine Enthusiast',
      'attributes': {
        'category': 'beverage',
        'type': 'like',
        'favorites': ['Pinot Noir', 'Champagne', 'Natural wines'],
        'notes': 'Prefer California wines. Learning about Burgundy.',
      },
    },
    // Activity Preferences
    {
      'nodeType': 'preference',
      'name': 'Morning Person',
      'attributes': {
        'category': 'lifestyle',
        'type': 'trait',
        'wake_time': '6:00 AM',
        'notes': 'Most productive before noon.',
      },
    },
    {
      'nodeType': 'preference',
      'name': 'Prefers Small Groups',
      'attributes': {
        'category': 'social',
        'type': 'trait',
        'notes': 'Quality over quantity. Max 6 people for dinners.',
      },
    },
  ];

  // ============================================
  // HOBBIES & INTERESTS
  // ============================================
  static final List<Map<String, dynamic>> hobbies = [
    {
      'nodeType': 'hobby',
      'name': 'Photography',
      'attributes': {
        'skill_level': 'intermediate',
        'equipment': 'Sony A7III',
        'favorite_subjects': ['Street', 'Travel', 'Food'],
        'instagram': '@user_photography',
        'notes': 'Shoot in RAW. Learning Lightroom.',
      },
    },
    {
      'nodeType': 'hobby',
      'name': 'Running',
      'attributes': {
        'skill_level': 'intermediate',
        'weekly_miles': 20,
        'races_completed': ['SF Half Marathon 2023', 'Bay to Breakers 2024'],
        'goal': 'Run a full marathon in 2025',
        'favorite_routes': ['Embarcadero', 'Golden Gate Park'],
      },
    },
    {
      'nodeType': 'hobby',
      'name': 'Cooking',
      'attributes': {
        'skill_level': 'intermediate',
        'favorite_cuisines': ['Italian', 'Japanese', 'Thai'],
        'signature_dishes': ['Cacio e Pepe', 'Homemade Ramen'],
        'notes': 'Want to learn French techniques.',
      },
    },
    {
      'nodeType': 'hobby',
      'name': 'Reading',
      'attributes': {
        'genres': ['Non-fiction', 'Sci-fi', 'Biographies'],
        'books_per_year': 25,
        'current_read': 'The Almanack of Naval Ravikant',
        'favorite_books': ['Sapiens', 'Zero to One', 'The Three-Body Problem'],
      },
    },
    {
      'nodeType': 'hobby',
      'name': 'Tennis',
      'attributes': {
        'skill_level': 'beginner',
        'plays_with': ['Alex Kim'],
        'location': 'Golden Gate Park Tennis Courts',
        'notes': 'Started 6 months ago. Need to improve serve.',
      },
    },
  ];

  // ============================================
  // WORK & CAREER
  // ============================================
  static final List<Map<String, dynamic>> work = [
    {
      'nodeType': 'company',
      'name': 'Current Company',
      'attributes': {
        'role': 'Senior Software Engineer',
        'team': 'Platform',
        'start_date': '2022-03',
        'technologies': ['Go', 'Python', 'Kubernetes', 'React'],
        'notes': 'Great team. Working on infrastructure.',
      },
    },
    {
      'nodeType': 'company',
      'name': 'Uber',
      'attributes': {
        'role': 'Software Engineer',
        'team': 'Payments',
        'start_date': '2019-06',
        'end_date': '2022-02',
        'technologies': ['Java', 'Go', 'MySQL'],
        'notes': 'Learned a lot about scale. Met Alex here.',
      },
    },
    {
      'nodeType': 'skill',
      'name': 'Go Programming',
      'attributes': {
        'proficiency': 'expert',
        'years_experience': 5,
        'notes': 'Primary language at work.',
      },
    },
    {
      'nodeType': 'skill',
      'name': 'System Design',
      'attributes': {
        'proficiency': 'advanced',
        'notes': 'Good at distributed systems.',
      },
    },
  ];

  // ============================================
  // TOPICS & INTERESTS
  // ============================================
  static final List<Map<String, dynamic>> topics = [
    {
      'nodeType': 'topic',
      'name': 'AI & Machine Learning',
      'attributes': {
        'interest_level': 'high',
        'podcasts': ['Lex Fridman', 'Machine Learning Street Talk'],
        'notes': 'Fascinated by LLMs. Building side project with embeddings.',
      },
    },
    {
      'nodeType': 'topic',
      'name': 'Personal Finance',
      'attributes': {
        'interest_level': 'medium',
        'investments': ['Index funds', 'Some crypto', 'Angel investing'],
        'notes': 'Maxing out 401k. Interested in angel investing.',
      },
    },
    {
      'nodeType': 'topic',
      'name': 'Climate Tech',
      'attributes': {
        'interest_level': 'medium',
        'notes': 'Would consider working in this space.',
      },
    },
  ];

  // ============================================
  // RELATIONSHIPS (Edges)
  // ============================================
  static final List<Map<String, dynamic>> relationships = [
    // Friend relationships
    {'from': 'Sarah Chen', 'to': 'Marcus Johnson', 'type': 'knows'},
    {'from': 'Sarah Chen', 'to': 'Jessica Park', 'type': 'friend_of'},
    {'from': 'Emily Rodriguez', 'to': 'Sarah Chen', 'type': 'knows'},
    {'from': 'Alex Kim', 'to': 'Priya Sharma', 'type': 'knows'},

    // Work relationships
    {'from': 'David Thompson', 'to': 'Priya Sharma', 'type': 'manages'},
    {'from': 'Mike Chen', 'to': 'Priya Sharma', 'type': 'works_with'},

    // Place visits
    {'from': 'Sarah Chen', 'to': 'Lazy Bear', 'type': 'recommended'},
    {'from': 'Emily Rodriguez', 'to': 'Burma Superstar', 'type': 'recommended'},
    {'from': 'Alex Kim', 'to': 'Sightglass Coffee', 'type': 'frequent_visitor'},

    // Event attendance
    {'from': 'Sarah Chen', 'to': 'Outside Lands 2024', 'type': 'attended'},
    {'from': 'Marcus Johnson', 'to': 'Outside Lands 2024', 'type': 'attended'},
    {'from': 'Emily Rodriguez', 'to': 'Coldplay Concert', 'type': 'attended'},
    {'from': 'Sarah Chen', 'to': 'Japan Trip 2024', 'type': 'traveled_with'},

    // Music preferences
    {'from': 'Tyler, The Creator', 'to': 'Outside Lands 2024', 'type': 'performed_at'},
    {'from': 'Coldplay', 'to': 'Coldplay Concert', 'type': 'performed_at'},

    // Location relationships
    {'from': 'Lazy Bear', 'to': 'Dolores Park', 'type': 'near'},
    {'from': 'Tartine Manufactory', 'to': 'Dolores Park', 'type': 'near'},
    {'from': 'Trick Dog', 'to': 'ABV', 'type': 'near'},

    // Work relationships
    {'from': 'Alex Kim', 'to': 'Uber', 'type': 'worked_at'},

    // Hobby relationships
    {'from': 'Alex Kim', 'to': 'Tennis', 'type': 'plays'},
    {'from': 'Jessica Park', 'to': 'Running', 'type': 'does'},
    {'from': 'Sarah Chen', 'to': 'Photography', 'type': 'interested_in'},
  ];

  /// Get all nodes as a flat list
  static List<Map<String, dynamic>> getAllNodes() {
    return [
      ...people,
      ...places,
      ...events,
      ...music,
      ...preferences,
      ...hobbies,
      ...work,
      ...topics,
    ];
  }
}
