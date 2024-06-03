$videoUrl = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
$videoPath = "c:/temp/video.mp3"

# Download the video using Invoke-WebRequest
Invoke-WebRequest -Uri $videoUrl -OutFile $videoPath

# Create a MediaPlayer object and set the source to the downloaded video
Add-Type -AssemblyName System.Windows.Media
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open($videoPath)

# Play the audio from the video
$player.Play()