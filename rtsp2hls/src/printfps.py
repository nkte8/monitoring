from camera import VideoCamera
import sys
from time import sleep

if __name__ == '__main__':
    args = sys.argv
    addr = str(args[1])
    print(f'> capture: rtsp://{addr}:8554/unicast', file=sys.stderr)
    for i in range(10):
        cap = VideoCamera(f"rtsp://{addr}:8554/unicast")
        sleep(i)
        fps = cap.get_fps()
        if fps <= 60:
            print(f'get value fps={fps}: printed stdout SEG_FPS={str(fps)}', file=sys.stderr)
            break
        print(f'invalid value fps={fps} continue...', file=sys.stderr)
        cap = None
    print(f"SEG_FPS={str(fps)}")
