from camera import VideoCamera
import sys
from time import sleep

if __name__ == '__main__':
    args = sys.argv
    addr = str(args[1])
    print(f'> capture: rtsp://{addr}:8554/unicast', file=sys.stderr)
    fps = None
    for i in range(10):
        cap = VideoCamera(f"rtsp://{addr}:8554/unicast")
        sleep(i)
        if cap.isOpened() == False:
            cap = None
            continue
        fps = cap.get_fps()
        if fps is not None: 
            break
        print(f'invalid value fps={fps} continue...', file=sys.stderr)
    if cap is None:
        sys.exit(2)
    cap = None
    if fps is None:
        sys.exit(1)    
    print(f'get value fps={fps}: printed stdout SEG_FPS={str(fps)}', file=sys.stderr)
    print(f"SEG_FPS={str(fps)}")
