package edu.iastate.cs472.proj1;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
/**
 *
 * @Joseph
 *
 */

public class PuzzleSolver_3 {
    public static void main(String[] args) {
        try {
            String puzzleFileName = "8Puzzle_3.txt";
            PrintWriter writer = new PrintWriter(new FileWriter(puzzleFileName));
            writer.println("1 2 3");
            writer.println("5 0 6");
            writer.println("4 7 8");
            writer.close();

            State initialState = new State(puzzleFileName);
            System.out.println("Initial State:");
            System.out.println(initialState);

            String solution = EightPuzzle.solve8Puzzle(initialState);
            System.out.println("--- Solution ---");
            System.out.println(solution);

        } catch (IOException e) {
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            System.out.println("Invalid puzzle input: " + e.getMessage());
        }
    }
}
