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
		
		//public var laser:b2Body;
		
		public function TestBounce(){
			// Set Text field
			Main.m_aboutText.text = "Bounce";
			
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
                             1.01;
                             // 1.05;
			fd.userData="circle";

			var body:b2Body;

			bd.position.Set(100 / m_physScale, 120 / m_physScale);
            body = m_world.CreateBody(bd);
			body.CreateFixture(fd);

			bd.position.Set(540 / m_physScale, 0 / m_physScale);
            body = m_world.CreateBody(bd);
			body.CreateFixture(fd);
		}
	
		//======================
		// Member Data 
		//======================
		
		public override function Update():void{
            lockFloorPosition();
            MouseTilt(floor);
			super.Update();
            lockFloorPosition();
		}

        private function lockFloorPosition():void{
            var position:b2Vec2 = new b2Vec2(640 / m_physScale / 2,
                (360 + 95 - 50) / m_physScale);
			floor.SetPosition(position);
        }

		//======================
		// Mouse Tilt
		//======================
		public function MouseTilt(floor:b2Body):void{
            var screenWidth:Number = 640.0;
            var fraction:Number = Input.mouseX / screenWidth;
            var tiltFraction:Number = fraction - 0.5;
            var tiltMaxRate:Number = // 0.25;
                                     // 0.5;
                                     1.0;
            var tiltMax:Number = tiltMaxRate * Math.PI;
            var angle:Number = tiltFraction * tiltMax;
            floor.SetAngle(angle);
		}
	}
	
}
