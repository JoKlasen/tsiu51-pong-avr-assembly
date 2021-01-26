TSIU51
Mikroprojekt
Medlemmar: Oskar Lundh, Johan Klasén



Beskrivning:
Spelet Pong bygger på en rektangulär spelplan, där det på två motstående sidor finns ett spelarstyrt racket. En boll "servas" från mitten och kan studsa på dom två sidorna som inte har racket,
och nuddar bollen en av racketsidorna så får motstående spelare ett poäng. Spelarna kan flytta sitt racket längs med sin sida och målet är att förhindra att bollen kommer igenom, samtidigt som man styr in den på motståndarens sida.
Vi vill försöka göra detta spel med hjälp av hårdvaran på ett DAvid-kort och någon form av display.

Skall-krav:
    * Spelet ska visas på en display (1 eller 2 DAmatrix, alt 64x128).
    * Styrs av båda joysticksen av två spelare.
    * Spelet startar med en knapptryckning.
    * Båda 7-segmentsdisplayerna visar respektive spelares poäng.
    * Varje spel går i set (typ bäst av/först till 3 eller 5).
    * Poäng och vinster skrivs ut som meddelande på LCDn (Player 1 o 2 eller vänster/höger).


Utökade krav:
    * Kunna välja namn på båda spelare. (Rotary + knappar).
    * Ljud till spelet.
    * Enkelt menysystem för 1-2 spelare (antal).
    * Bygga en “AI” för enspelarläge (ev så enkelt som att ena racket rör sig slumpmässigt eller alltid kontrar bollen).

    * ((Om mycket tid över och alla rutiner för moduler är igång, lägga till ytterligare enkelt spel + menyval, typ snake/4-i-rad))

Komponenter:
    * DAvid-kort
    * DAmatrix

