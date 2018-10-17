using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateInPoint : MonoBehaviour {
	public Vector3 targetPoint;
	public float speed;
	void FixedUpdate()
	{
        this.transform.RotateAround(targetPoint, Vector3.up, speed* Time.deltaTime);
	}
}
