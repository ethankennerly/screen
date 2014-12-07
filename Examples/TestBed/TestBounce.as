/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/


package TestBed{
	
    import flash.geom.Rectangle;	
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import General.Input;
	
	
	
	public class TestBounce extends Test{
		
		private static var bounceCount:int = 0;
		private static var bounceCountMax:int = 0;
		private static var onBounceCountIndex:int = 0;

		private var balls:Array;
		private var ballsPrevious:Array;
        private var centerFraction:Number = 0.5;
		private var isPlaying:Boolean = false;
        private var screen:Rectangle;
        private var screenWidth:Number = 640.0;
        private var screenHeight:Number = 360.0;

		private var spawnXFractions:Array = [0.25, 0.75, 0.5, 0.375, 0.675];
        /**
         * 2014-12-05 About 20 bounces. Anders Sajbel may expect a 3rd ball to bounce.
         */
		private var onBounceCounts:Array = [0, 5, 
            30,
            // 50, 
            100, 200, 400, 600, 1000, 2000, 5000];
		
        private var box:b2PolygonShape;
        private var fd:b2FixtureDef;
        private var bd:b2BodyDef;
        private var circle:b2CircleShape;
        private var body:b2Body;

		public function TestBounce(){
			Main.m_aboutText.text = "MOUSE tilts floor. CLICK makes ball."
			m_world.SetGravity(new b2Vec2(0,10));
            screen = new Rectangle(0, 0, 1.1 * screenWidth / m_physScale, 
                                         1.5 * screenHeight / m_physScale)
            balls = [];
            ballsPrevious = [];
		}

        /**
         * 2014-12-05 Jennifer Russ may expect to start and restart.
         */
        private function start():void{
            if (isPlaying) {
                return;
            }
            isPlaying = true;
            bounceCount = 0;
		    onBounceCountIndex = 0;
			Main.m_aboutText.text = "";
        }

        private function reset():void{
            Main.m_currTest = null
        }

		public override function Update():void{
			if (Input.mouseDown){
                start();
            }
		    if (isOffscreen(balls)) {
                reset();
            }
            if (isPlaying) {
                if (isNextBounceCount(bounceCount)) {
                    spawnBall(onBounceCountIndex);
                    onBounceCountIndex++;
                }
            }
            var bounceNormal:Number = bounce(balls);
            if (0 != bounceNormal) {
                bounceCount++;
                bounceCountMax = Math.max(bounceCount, bounceCountMax);
                deflectCenter(bounceNormal);
            }
			Main.instructions_text.text = "Bounces " + bounceCount 
                + " of " + onBounceCounts[onBounceCountIndex]
                + "\nHigh Score " + bounceCountMax;
            floor.SetAngle(MouseTilt());
			super.Update();
		}

        /**
         * 2014-12-05 Anders Sajbel may expect another ball to spawn. Got bored.
         */
        private function isNextBounceCount(bounceCount:int):Boolean{
            if (onBounceCounts.length - 1 <= onBounceCountIndex) {
                return false;
            }
            if (onBounceCounts[onBounceCountIndex] <= bounceCount) {
                return true;
            }
            else {
                return false;
            }
        }

        private function spawnBall(index:int):void{
            box = new b2PolygonShape();
            fd = new b2FixtureDef();
            bd = new b2BodyDef();
            circle = new b2CircleShape(30 / m_physScale);
			
            bd.type = b2Body.b2_dynamicBody;
			fd.shape = circle;
			fd.density = 4;
			fd.friction = // 0.4;
                          // 1.0;
                          4.0;
			fd.restitution = // 0.3;
                             // 0.75;
                             1.0;
                             // 1.01;
                             // 1.05;
			fd.userData = "circle";
            index = index % spawnXFractions.length;
            var x:Number = screenWidth * spawnXFractions[index] / m_physScale;
            var y:Number = 0 / m_physScale;
			bd.position.Set(x, y);
            body = m_world.CreateBody(bd);
			body.CreateFixture(fd);
            balls.push(body);
            ballsPrevious.push({isDescending: true, y: y});
        }

		private function isOffscreen(balls:Array):Boolean{
            for (var b:int = 0; b < balls.length; b++) {
                var pos:b2Vec2 = balls[b].GetPosition();
                if (screen.bottom < pos.y 
                || pos.x < screen.left || screen.right < pos.x) {
                    return true;
                }
            }
            return false;
        }

        /**
         * @return  0 if no bounce.  normalized screen position if bounce.
         */
		private function bounce(balls:Array):Number{
            var bounceNormal:Number = 0;
            for (var b:int = 0; b < balls.length; b++) {
                var previous:Object = ballsPrevious[b];
                var pos:b2Vec2 = balls[b].GetPosition();
                if (previous.isDescending) {
                    if (pos.y < previous.y) {
                        previous.isDescending = false;
                        bounceNormal = pos.x / m_physScale / screenWidth;
                        if (0 == bounceNormal) {
                            bounceNormal = 0.001 * (Math.random() < 0.5 ? 1 : -1);
                        }
                        return bounceNormal;
                    }
                }
                else {
                    previous.isDescending = previous.y < pos.y;
                }
                previous.y = pos.y;
            }
            return bounceNormal;
        }

        /**
         * Ball deflects floor. 2014-12-05 Anders Sajbel expects to need to adjust position.  Got bored.
         */
		private function deflectCenter(xFraction:Number):void{
            xFraction = Math.max(0, Math.min(1, xFraction));
            var tiltFraction:Number = xFraction - 0.5;
            var tiltMax:Number = // 0.001;
                                 0.0025;
                                 // 0.01;
                                 // 0.1;
            var tilt:Number = tiltMax * tiltFraction;
            centerFraction -= tilt;
            centerFraction = Math.max(0.25, Math.min(0.75, centerFraction));
            // trace("deflectCenter: " + centerFraction);
        }

        /**
         * 2014-12-05 Jennifer Russ may expect maximum angle of floor.
         */
		public function MouseTilt():Number{
            var fraction:Number = Input.mouseX / screenWidth;
            var tiltFraction:Number = fraction - centerFraction;
            var tiltMaxRate:Number = // 0.25;
                                     // 0.5;
                                     1.0;
            tiltMaxRate = Math.max(-0.25, Math.min(0.25, tiltMaxRate));
            var tiltMax:Number = tiltMaxRate * Math.PI;
            var angle:Number = tiltFraction * tiltMax;
            return angle;
		}
	}
	
}
