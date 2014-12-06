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
	
	
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import General.Input;
	
	
	
	public class TestBounce extends Test{
		
		private var balls:Array;
		private var bounceCount:int;
        private var centerFraction:Number = 0.5;
        private var screenWidth:Number = 640.0;
		private var ballsPrevious:Array;
		
		public function TestBounce(){
			Main.instructions_text.text = "How long can you keep all balls on screen?\nMove mouse to tilt floor.\nPress R: reset."
			m_world.SetGravity(new b2Vec2(0,10));
			
			var ground:b2Body = m_world.GetGroundBody();
			
			var box:b2PolygonShape = new b2PolygonShape();
			var fd:b2FixtureDef = new b2FixtureDef();
			var bd:b2BodyDef = new b2BodyDef();
			bd.type = b2Body.b2_dynamicBody;
			
			var circle:b2CircleShape = new b2CircleShape(30 / m_physScale);
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
			fd.userData="circle";

			var body:b2Body;
            balls = [];
            ballsPrevious = [];
            bounceCount = 0;
			bd.position.Set(100 / m_physScale, 120 / m_physScale);
            body = m_world.CreateBody(bd);
			body.CreateFixture(fd);
            balls.push(body);
            ballsPrevious.push({isDescending: true, y: body.GetPosition().y});

			bd.position.Set(540 / m_physScale, 0 / m_physScale);
            body = m_world.CreateBody(bd);
			body.CreateFixture(fd);
            balls.push(body);
            ballsPrevious.push({isDescending: true, y: body.GetPosition().y});
		}
	
		//======================
		// Member Data 
		//======================
		
		public override function Update():void{
            ifBounce(balls, deflectCenter);
			Main.m_aboutText.text = "Bounces " + bounceCount;
            MouseTilt(floor);
			super.Update();
		}

		private function ifBounce(balls:Array, deflect:Function):void{
            for (var b:int = 0; b < balls.length; b++) {
                var previous:Object = ballsPrevious[b];
                var pos:b2Vec2 = balls[b].GetPosition();
                if (previous.isDescending) {
                    if (pos.y < previous.y) {
                        bounceCount++;
                        previous.isDescending = false;
                        deflect(pos.x / m_physScale / screenWidth);
                    }
                }
                else {
                    previous.isDescending = previous.y < pos.y;
                }
                previous.y = pos.y;
            }
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
            trace("deflectCenter: " + centerFraction);
        }

		//======================
		// Mouse Tilt
		//======================
		public function MouseTilt(floor:b2Body):void{
            var fraction:Number = Input.mouseX / screenWidth;
            var tiltFraction:Number = fraction - centerFraction;
            var tiltMaxRate:Number = // 0.25;
                                     // 0.5;
                                     1.0;
            var tiltMax:Number = tiltMaxRate * Math.PI;
            var angle:Number = tiltFraction * tiltMax;
            floor.SetAngle(angle);
		}
	}
	
}
