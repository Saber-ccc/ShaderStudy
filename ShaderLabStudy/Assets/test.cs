using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class test : MonoBehaviour
{
    public Transform po1;
    public Transform po2;

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(1))
        {
            var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            Collider[] hit = Physics.OverlapCapsule(po1.position, po2.position, 5);
            if (hit.Length >0)
            {
                for (int i = 0; i < hit.Length; i++)
                {
                    Debug.Log(hit[i].gameObject.name);
                }
          
            }
        }
        
    }
}
