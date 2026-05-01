<img width="2948" height="497" alt="image" src="https://github.com/user-attachments/assets/f4ef4273-587c-4b44-8036-54c50cdef91f" />

Added Discord Logs for the RSG Bathing main script and more bathing locations. 

🛁 rsg-bathing
Interactive bathing system for RedM servers using RSG Core.

Immersive bathhouses where players can pay for a normal or deluxe bath.
Includes realistic animations, NPC attendants, and localized prompts for Saint Denis, Valentine, and Annesburg.

🛠️ Dependencies
rsg-core 🤠
ox_lib ⚙️ (for prompts and notifications)
oxmysql 🗄️ (for character data)

✨ Features

🧭 Bathing System
Available in Saint Denis, Valentine, Annesburg, Strawberry, Blackwater, Van Horn, Rhodes and Tumbleweed.
Choose between:
Normal Bath → base price 
Deluxe Bath → assisted version 
Dynamic NPC attendants spawn at each bathhouse.
Integrated blips and prompts for easy interaction.

💰 Payment Logic
Server-side validation via RSG Core (Player.Functions.RemoveMoney('cash')).
Prevents simultaneous use — only one player per bath at a time.
Notifies players if:
- insufficient funds (notify_not_enough_money)
- bath is already occupied (notify_occupied).

🎬 Immersive Animations
Uses RDR2 native bathing animations:
- script@mini_game@bathing@BATHING_INTRO_OUTRO_ST_DENIS
- script@mini_game@bathing@BATHING_INTRO_OUTRO_VALENTINE
- script@mini_game@bathing@BATHING_INTRO_OUTRO_ANNESBURG
Includes door closing, ragdoll positioning, and fade effects.

Credits 
RedShack - https://github.com/Rexshack-RedM/rsg-core
