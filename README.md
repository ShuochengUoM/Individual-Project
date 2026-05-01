# IFDA-Based Distributed Economic Dispatch Simulation for a Six-Generator Power System

## 1. Title

**IFDA-Based Distributed Economic Dispatch Simulation for a Six-Generator Power System**

This repository contains the MATLAB/Simulink implementation developed for the final year project on distributed optimisation-based economic dispatch. The software is used to simulate an Incremental Finite-time Distributed Algorithm (IFDA) for a six-generator power system under normal operation, generator outage, reconnection, and constrained dispatch conditions.

---

## 2. Introduction

This software implements a distributed economic dispatch simulation using MATLAB and Simulink. The aim of the simulation is to evaluate how a group of generators can cooperatively reach an optimal generation allocation without relying on a centralised controller. Each generator is treated as an agent and exchanges information with neighbouring agents through a predefined communication graph.

The software supports the main simulation results presented in the final report. It produces the generator output trajectories, local Lagrangian multiplier responses, power mismatch curves, reconnection transient response, and total generation cost comparison. These results are used to assess the dynamic behaviour of the IFDA-based distributed optimisation method under different operating stages.

---

## 3. Contextual Overview

The overall simulation structure is based on a six-generator economic dispatch problem. Each generator has a local quadratic cost function and active power generation limits. The total generation must meet the total demand while minimising the overall generation cost.

The simulation is divided into the following operating stages:

| Stage      | Time interval | Description                                                  |
| ---------- | ------------: | ------------------------------------------------------------ |
| Phase 1    |       0-300 s | All six generators are online                                |
| Phase 2    |     300-500 s | Unit 1 is disconnected from the system                       |
| Transition |     500-502 s | Unit 1 is guided back using a reference-tracking interval    |
| Phase 3    |   after 502 s | Unit 1 is reconnected and the full six-generator system is restored |

The Simulink model implements the dynamic IFDA update process. MATLAB scripts are used to initialise system parameters, define the communication topology, run the simulation setup, process the output data, and generate the figures used in the final report.

The main information flow is:

    Initialisation script
            ↓
    Generator parameters, demand profile, graph Laplacian, operating limits
            ↓
    Simulink IFDA model
            ↓
    Pg, lambda, mismatch, total cost
            ↓
    Plotting scripts and result figures

---

## 4. Installation Instructions

### 4.1 Required Software

The project was developed using MATLAB and Simulink.

Recommended environment:

- MATLAB R2024a or later
- Simulink

The main simulation does not require an external code library. It is based on MATLAB scripts and a Simulink model.

### 4.2 Dependencies

The repository uses:

- MATLAB `.m` scripts
- Simulink `.slx` model
- PNG result figures
- CSV result table

No third-party MATLAB toolbox is intentionally required beyond MATLAB and Simulink. If a different MATLAB version is used, minor differences may occur in model loading, scope output formatting, or figure appearance.

### 4.3 Environment Setup

After downloading or cloning the repository, open MATLAB and set the repository root folder as the current working directory.

The expected folder structure is:

    IFDA-Distributed-Economic-Dispatch/
    |
    |-- README.md
    |-- .gitignore
    |
    |-- model/
    |   |-- IFDA_5_2_Test1_Simulink.slx
    |
    |-- scripts/
    |   |-- IFDA_5_2_Test1.m
    |
    |-- plotting/
    |   |-- IFDA_5_2_Test1plot_Cost_All.m
    |   |-- IFDA_5_2_Test1plot_lambda_Phase1.m
    |   |-- IFDA_5_2_Test1plot_lambda_Phase2.m
    |   |-- IFDA_5_2_Test1plot_lambda_Phase3.m
    |   |-- IFDA_5_2_Test1plot_mismatch_Phase1.m
    |   |-- IFDA_5_2_Test1plot_mismatch_Phase3.m
    |   |-- IFDA_5_2_Test1plot_Pg_Phase1.m
    |   |-- IFDA_5_2_Test1plot_Pg_Phase2.m
    |   |-- IFDA_5_2_Test1plot_Pg_Phase3.m
    |
    |-- results/
        |-- figures/
        |-- tables/

---

## 5. How to Run the Software

To reproduce the simulation results, follow the steps below.

### Step 1: Open MATLAB

Open MATLAB and set the current folder to the root directory of this repository.

### Step 2: Run the initialisation script

Run the main initialisation script:

    run('scripts/IFDA_5_2_Test1.m')

This script defines the system parameters, generator cost coefficients, generation limits, demand profile, communication topology, and simulation settings.

### Step 3: Open the Simulink model

Open the main Simulink model:

    open_system('model/IFDA_5_2_Test1_Simulink.slx')

### Step 4: Run the Simulink simulation

Run the model from the Simulink interface, or execute:

    sim('model/IFDA_5_2_Test1_Simulink.slx')

The model generates the simulation outputs, including generator power outputs, local Lagrangian multipliers, power mismatch, and total generation cost.

### Step 5: Generate figures

After the simulation has finished, run the plotting scripts in the `plotting/` folder. For example:

    run('plotting/IFDA_5_2_Test1plot_Pg_Phase1.m')
    run('plotting/IFDA_5_2_Test1plot_lambda_Phase1.m')
    run('plotting/IFDA_5_2_Test1plot_mismatch_Phase1.m')
    
    run('plotting/IFDA_5_2_Test1plot_Pg_Phase2.m')
    run('plotting/IFDA_5_2_Test1plot_lambda_Phase2.m')
    
    run('plotting/IFDA_5_2_Test1plot_Pg_Phase3.m')
    run('plotting/IFDA_5_2_Test1plot_lambda_Phase3.m')
    run('plotting/IFDA_5_2_Test1plot_mismatch_Phase3.m')
    
    run('plotting/IFDA_5_2_Test1plot_Cost_All.m')

The generated figures correspond to the simulation results presented in Chapter 4 of the final report. Existing output figures are stored in:

    results/figures/

The cost comparison table is stored in:

    results/tables/

---

## 6. Technical Details

### 6.1 Economic Dispatch Problem

The simulation is based on a constrained economic dispatch problem. The objective is to minimise the total generation cost:

$$
\min \sum_{i=1}^{N} C_i(P_{g,i})
$$

where \(P_{g,i}\) is the active power output of generator \(i\), and \(C_i(P_{g,i})\) is its generation cost function.

Each generator is modelled using a quadratic cost function:

$$
C_i(P_{g,i}) = a_i P_{g,i}^{2} + b_i P_{g,i} + c_i
$$

The dispatch must satisfy the power balance condition:

$$
\sum_{i=1}^{N} P_{g,i} = \sum_{i=1}^{N} P_{d,i}
$$

and the generator output limits:

$$
P_{g,i}^{\min} \leq P_{g,i} \leq P_{g,i}^{\max}
$$

### 6.2 Distributed Optimisation Algorithm

The Simulink model implements an IFDA-based distributed optimisation process. Each generator maintains local dynamic variables and communicates only with neighbouring generators according to the communication graph.

The communication topology is represented using a graph Laplacian matrix. During the outage stage, Unit 1 is disconnected and the communication links associated with this unit are removed. When Unit 1 is reconnected, the communication topology is restored.

### 6.3 Main Simulation Variables

| Variable    | Description                                          |
| ----------- | ---------------------------------------------------- |
| `Pg`        | Generator active power output                        |
| `lambda`    | Local Lagrangian multiplier variable                 |
| `mismatch`  | Difference between total generation and total demand |
| `totalcost` | Total system generation cost                         |
| `Lg`        | Communication graph Laplacian matrix                 |
| `s`         | Generator online/offline status signal               |
| `Pd`        | Local demand value                                   |

### 6.4 Design Assumptions

The main assumptions used in the simulation are:

- the communication graph is undirected;
- the generator cost functions are convex quadratic functions;
- generator active power limits are enforced through projection;
- the outage event affects both the generator status and its communication links;
- Unit 1 reconnection includes a short reference-tracking transition interval;
- the simulation is intended for academic validation rather than real-time power system control.

---

## 7. Known Issues and Future Improvements

### 7.1 Known Issues and Limitations

- The model is based on a six-generator test system and does not represent a full practical transmission network.
- The communication topology is modelled as an undirected graph.
- The generator cost functions are convex quadratic functions, so non-convex effects such as valve-point loading are not included.
- The reconnection of Unit 1 uses a predefined reference value during the transition interval.
- The current implementation focuses on simulation and result generation rather than real-time deployment.
- Figure formatting may vary slightly across MATLAB versions.

### 7.2 Future Improvements

Future work may include:

- extending the communication topology to directed or time-varying graphs;
- considering non-convex generation cost functions;
- developing a fully distributed reconnection mechanism;
- testing multiple generator outage and reconnection events;
- including renewable generation uncertainty and load fluctuations;
- extending the model to larger power systems.

---

## 8. Repository Contents

The repository contains the following main components:

| Folder             | Content                                                  |
| ------------------ | -------------------------------------------------------- |
| `model/`           | Main Simulink model used for the final report simulation |
| `scripts/`         | MATLAB initialisation script                             |
| `plotting/`        | MATLAB scripts used to generate result figures           |
| `results/figures/` | Output figures used in the final report                  |
| `results/tables/`  | Cost comparison table                                    |

The main Simulink model is:

    model/IFDA_5_2_Test1_Simulink.slx

The main initialisation script is:

    scripts/IFDA_5_2_Test1.m

---

## 9. Academic Integrity and Third-Party Code

The MATLAB scripts and Simulink model in this repository were developed for the final year project.

No third-party source code is directly included in this repository. The implementation is based on the distributed optimisation, resource allocation, graph theory, and economic dispatch formulations discussed and cited in the final report.

Any theoretical methods, equations, algorithms, or external references used to support the project are acknowledged in the final report. This repository is provided as software evidence for inspection, reuse, and reproducibility of the simulation work.

---

## 10. Author

Final Year Project  
Department of Electrical and Electronic Engineering  
University of Manchester
