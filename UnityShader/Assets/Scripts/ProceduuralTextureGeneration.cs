// using System.Collections;
// using System.Collections.Generic;
// using UnityEngine;

// [ExecuteInEditMode]
// public class ProceduuralTextureGeneration : MonoBehaviour {

// 	public Material material = null;

// 	#region Material properties
// 	[SerializeField,SetProperty("textureWidth")]
// 	private int m_textureWidth = 512;
// 	public int textureWidth
// 	{
// 		get
// 		{
// 			return m_textureWidth;
// 		}
// 		set
// 		{
// 			m_textureWidth = value;
// 			_UpdateMaterial();
// 		}
// 	}

// 	[SerializeField,SetProperty("backgroundColor")]
// 	private Color m_backgroundColor = Color.white;
// 	public Color backgroundColor
// 	{
// 		get
// 		{
// 			return m_backgroundColor;
// 		}
// 		set
// 		{
// 			m_backgroundColor = value;
// 			_UpdateMaterial();
// 		}
// 	}

// 	[SerializeField,SetProperty("circleColor")]
// 	private Color m_circleColor = Color.yellow;
// 	public Color circleColor
// 	{
// 		get
// 		{
// 			return m_circleColor;
// 		}
// 		set
// 		{
// 			m_circleColor = value;
// 			_UpdateMaterial();
// 		}
// 	}

// 	#endregion
// }
