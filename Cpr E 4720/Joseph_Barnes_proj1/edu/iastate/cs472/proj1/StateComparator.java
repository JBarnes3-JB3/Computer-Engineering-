package edu.iastate.cs472.proj1;

import java.util.Comparator;

/**
 *  
 * @Joseph
 *
 */

/**
 * This method compares two states in the lexicographical order of the board configuration. 
 * The 3X3 array representing each board configuration is converted into a sequence of nine 
 * digits starting at the 0th row, and within each row, at the 0th column.  For example, the 
 * two states
 * 
 * 	   2 0 3        2 8 1 
 *     1 8 4        7 5 3 
 *     7 6 5        6 0 4 
 *
 * are converted into the sequences <2,0,3,1,8,4,7,6,5>, and <2,8,1,7,5,3,6,0,4>, respectively. 
 * By definition the first state is less than the second one.  
 * 
 * The comparator will be used for maintaining the CLOSED list used in the A* algorithm. 
 */
public class StateComparator implements Comparator<State>
{
	@Override
	public int compare(State s1, State s2)
	{
		int[][] b1 = s1.board;
    int[][] b2 = s2.board;

    // Compare board cells in row-major order
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            if (b1[i][j] < b2[i][j]) {
                return -1; // s1 is smaller
            } else if (b1[i][j] > b2[i][j]) {
                return 1;  // s1 is larger
            }
        }
	}
	    return 0;
	}  		
}
