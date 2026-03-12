final Map<String, List<String>> messageSuggestions = {
  'Birthday': [
    "Happy Birthday! 🎂 Wishing you joy & surprises.",
    "Cheers to a new year full of happiness! 🎉"
  ],
  'Romantic': [
    "You’re my everything ❤.",
    "A little surprise for my love 💕. "
        "I love you so mush than I can express, you are a world to me"
  ],
  'Sallah': [
    "Eid Mubarak! 🌙 May your life be blessed.",
    "Wishing you endless blessings this Sallah."
  ],
  // Add other categories...
};


final Map<String, List<String>> aiSuggestions = {
  'Birthday 🎂': [
    "Happy Birthday! 🎉 May your special day be filled with laughter, endless joy, and beautiful surprises that remind you how loved you truly are.",
    "Wishing you the most wonderful birthday ever! 🥳 May this new chapter bring success, happiness, and memories you’ll cherish forever.",
    "On your birthday, I hope you take time to celebrate yourself and all the amazing things you’ve achieved. You deserve the best of everything! 🎂",
    "Another year older, wiser, and even more incredible than before. May today mark the start of your brightest chapter yet!",
    "Happy Birthday! 🎊 Sending you wishes for good health, boundless happiness, and countless reasons to smile.",
    "Birthdays are nature’s way of reminding us to eat more cake 🎂, laugh louder, and love harder. Have the sweetest day ever!",
    "Cheers to you on your special day 🥂 May your dreams find wings and every step forward lead you closer to your goals.",
    "Today is your day to shine like the star you are 🌟. May love and blessings surround you always.",
    "Wishing you happiness that multiplies, dreams that come true, and friendships that last a lifetime. Happy Birthday! 💖",
    "As you celebrate another trip around the sun 🌍, may your life glow brighter and your days grow sweeter."
  ],
  'Romantic/ Love 💝': [
    "You are my heart, my happiness, and the most beautiful chapter of my life. 💕",
    "No words can ever capture the depth of love I feel for you — every day with you feels like a blessing written in the stars.",
    "Your love is my safe place, my greatest adventure, and the reason behind my smile. 💝",
    "When I look at you, I see my today, my tomorrow, and my forever wrapped in one soul.",
    "I never believed in fairy tales until I met you, now every moment feels like magic sprinkled with love.",
    "If I could hold time still, it would be in the moments when you’re in my arms, because that’s where happiness lives.",
    "You are the melody to my heart’s song, the rhythm to my soul, and the light that guides my path.",
    "My love for you only grows deeper with every heartbeat, stronger with every day we share. 💖",
    "Being with you is my favorite place to be. Whether it’s sunshine or storms, I’ll choose you every single time.",
    "You’re not just my love, you’re my everything — my peace, my joy, my forever home."
  ],
  'Eid 🕌': [
    "Eid Mubarak! 🌙 May Allah bless your home with love, your heart with faith, and your life with endless happiness.",
    "On this blessed occasion of Eid, I pray that your days are filled with light, your heart with peace, and your future with prosperity.",
    "Eid is a time for sharing smiles, spreading kindness, and embracing loved ones. May you be surrounded by blessings today and always.",
    "Wishing you a joyful Eid filled with the warmth of family, the joy of friends, and the serenity of faith.",
    "May this Eid bring you closer to Allah and shower your life with His infinite mercy and grace.",
    "On this special day, let’s celebrate with gratitude, love, and joy. Eid Mubarak to you and your loved ones! 🕌",
    "Eid is not just about new clothes or delicious food, it’s about renewing faith, strengthening bonds, and sharing happiness.",
    "As the crescent moon shines bright, may your heart glow with faith and your home with countless blessings. 🌙",
    "Sending you prayers and warm wishes for an Eid that is filled with joy, peace, and unending blessings.",
    "Eid Mubarak! May Allah answer your prayers, accept your sacrifices, and grant you lasting happiness."
  ],
  'Christmas 🎄': [
    "Merry Christmas! 🎄 May your heart be filled with the joy of the season and your home with love and warmth.",
    "Christmas is not about presents under the tree, it’s about the love we share with one another. Wishing you the best this season.",
    "May this holiday season wrap you in comfort, surround you with love, and bring peace to your heart.",
    "Merry Christmas! 🌟 May the spirit of giving and joy brighten your life now and always.",
    "Wishing you magical moments, beautiful memories, and the happiest of holidays.",
    "The true spirit of Christmas lives in kindness, gratitude, and love. May your days be blessed with all three.",
    "Christmas reminds us of hope, love, and unity. May this season bring you and your loved ones closer together.",
    "May the beauty of Christmas light up your life with peace, joy, and unforgettable memories.",
    "Merry Christmas! 🎁 Here’s to family, friends, and the countless blessings of this season.",
    "As the snow falls, may your troubles fade away and your heart be warmed by love and happiness."
  ],
  'New Year 🗽': [
    "Happy New Year! 🎉 May this year bring you endless opportunities, new beginnings, and the courage to chase your dreams.",
    "Here’s to a year filled with health, happiness, and love. Let’s make every day of this New Year count!",
    "May 2025 be the year where your hard work pays off and your dreams come alive. 🗽",
    "Wishing you new adventures, greater achievements, and a heart full of joy this coming year.",
    "The best time for new beginnings is now — may this New Year be the fresh start you’ve been waiting for.",
    "As the clock strikes midnight, may you leave behind worries and step into a year filled with hope and joy.",
    "Happy New Year! May success find you in unexpected places and happiness follow you everywhere.",
    "Cheers to health, love, and happiness. Let’s embrace this new year with courage and hope.",
    "May every day of this year inspire you to live fully, love deeply, and dream boldly.",
    "2025 is your year to shine — claim it with confidence and live it with joy."
  ],
  'Friendship 🤝': [
    "True friendship is not measured by time, but by the countless memories and love shared along the way. 🤝",
    "You’re not just my friend, you’re my chosen family, and I’m grateful every day for the bond we share.",
    "In a world full of temporary things, our friendship is one of the few constants I treasure deeply.",
    "Thanks for always being my safe space, my laughter partner, and my shoulder to lean on.",
    "Life is brighter with friends like you who turn ordinary days into unforgettable adventures.",
    "Our friendship is the glue that keeps my happiness together, no matter what life throws at us.",
    "Good friends are like stars 🌟, you may not always see them but you know they’re always there.",
    "You’re the kind of friend who makes even silence feel comfortable and presence feel priceless.",
    "To the friend who knows all my flaws yet still chooses to stand by me — thank you.",
    "Friendship like ours is rare, precious, and something I’ll always hold close to my heart."
  ],
  'Appreciation 🙏': [
    "Thank you for always being there when I needed you most — your kindness is a gift I’ll never forget. 🙏",
    "Words will never be enough to express my gratitude for your support and encouragement.",
    "Your help came at a time when I needed it most, and I’m forever grateful for your generosity.",
    "Appreciation is more than words — it’s the deep sense of gratitude I feel every time I think of you.",
    "Thank you for making a difference in my life with your kindness, patience, and support.",
    "I’m truly blessed to have someone as thoughtful and giving as you in my corner.",
    "Your actions, big or small, have left a lasting impact on my heart. Thank you.",
    "I appreciate the love, care, and effort you’ve shown me — it means more than you’ll ever know.",
    "Gratitude fills my heart when I think of how much you’ve contributed to my happiness.",
    "Thank you for your unwavering support, your time, and most importantly, your presence."
  ],
  'Valentine 💝': [
    "Happy Valentine’s Day! 💝 You are the love of my life, my forever, and my greatest blessing.",
    "Every day with you feels like Valentine’s Day — full of love, laughter, and sweet moments.",
    "You’ve turned my ordinary life into an extraordinary love story, and I’ll cherish you forever.",
    "Valentine’s Day is just one day, but my love for you is endless and eternal.",
    "You are my dream come true, my partner, and my forever Valentine. 💕",
    "With every heartbeat, I love you more and more. Thank you for being my everything.",
    "Valentine’s Day reminds me how lucky I am to have you as my best friend and soulmate.",
    "You make love feel effortless, magical, and beautifully real. Happy Valentine’s Day!",
    "There’s no one else I’d rather share this life with than you. You’re my world.",
    "To my Valentine — my love, my peace, and my greatest adventure."
  ],
  'Graduation 🎓': [
    "Congratulations on your graduation! 🎓 You’ve worked hard, and today is a celebration of your perseverance and success.",
    "Graduation is not the end, it’s the beginning of a new journey filled with endless opportunities.",
    "Your dedication and commitment have paid off — now the world is ready for your greatness.",
    "This milestone proves your strength and resilience. I’m so proud of you!",
    "Graduating is not just about academics, it’s about growth, determination, and courage.",
    "Congratulations! May this achievement open doors to greater dreams and brighter futures.",
    "You’ve turned your challenges into stepping stones — now nothing can hold you back.",
    "This is just the beginning of the amazing future you’ve always deserved. Keep shining!",
    "Celebrate this success, but know the best is yet to come. 🎉",
    "Your graduation is proof that hard work, sacrifice, and faith always pay off."
  ],
  'Get Well Soon ❤️‍🩹': [
    "Wishing you a smooth and speedy recovery. May each day bring you closer to full health. ❤️‍🩹",
    "Take this time to rest and heal. Your strength and spirit will carry you through.",
    "I’m sending you love, positivity, and prayers for a quick recovery.",
    "Get well soon! The world is waiting for your smile, your laughter, and your energy.",
    "Healing takes time, but know that we’re here cheering for you every step of the way.",
    "May your days be filled with hope, comfort, and steady healing.",
    "Don’t worry, better days are coming — your strength is greater than this challenge.",
    "Wishing you brighter days ahead, filled with health, peace, and joy.",
    "You’re stronger than you think, and you’ll overcome this setback with grace.",
    "Get well soon! We can’t wait to see you back to your wonderful self."
  ],
};

