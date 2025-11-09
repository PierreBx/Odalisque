#!/bin/bash
# Helper script to run Flutter commands in Docker

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Flutter Docker Test Runner${NC}"
echo "================================"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: docker-compose not found${NC}"
    exit 1
fi

# Function to run a command
run_command() {
    local service=$1
    local description=$2

    echo ""
    echo -e "${BLUE}Running: ${description}${NC}"
    echo "--------------------------------"

    docker-compose run --rm ${service}
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ ${description} completed successfully${NC}"
    else
        echo -e "${RED}✗ ${description} failed with exit code ${exit_code}${NC}"
    fi

    return $exit_code
}

# Parse command line arguments
case "$1" in
    test)
        run_command flutter-test "Unit Tests"
        ;;
    analyze)
        run_command flutter-analyze "Code Analysis"
        ;;
    shell)
        echo -e "${BLUE}Opening interactive shell...${NC}"
        docker-compose run --rm flutter-shell /bin/bash
        ;;
    all)
        echo -e "${BLUE}Running full test suite...${NC}"

        run_command flutter-analyze "Code Analysis"
        analyze_exit=$?

        run_command flutter-test "Unit Tests"
        test_exit=$?

        echo ""
        echo "================================"
        if [ $analyze_exit -eq 0 ] && [ $test_exit -eq 0 ]; then
            echo -e "${GREEN}✓ All tests passed!${NC}"
            exit 0
        else
            echo -e "${RED}✗ Some tests failed${NC}"
            exit 1
        fi
        ;;
    grist-start)
        echo -e "${BLUE}Starting Grist server...${NC}"
        docker-compose up -d grist
        echo -e "${GREEN}✓ Grist started at http://localhost:8484${NC}"
        ;;
    grist-stop)
        echo -e "${BLUE}Stopping Grist server...${NC}"
        docker-compose stop grist
        echo -e "${GREEN}✓ Grist stopped${NC}"
        ;;
    grist-logs)
        echo -e "${BLUE}Showing Grist logs...${NC}"
        docker-compose logs -f grist
        ;;
    grist-restart)
        echo -e "${BLUE}Restarting Grist server...${NC}"
        docker-compose restart grist
        echo -e "${GREEN}✓ Grist restarted${NC}"
        ;;
    start-all)
        echo -e "${BLUE}Starting all services...${NC}"
        docker-compose up -d
        echo -e "${GREEN}✓ All services started${NC}"
        echo -e "${GREEN}✓ Grist available at http://localhost:8484${NC}"
        ;;
    stop-all)
        echo -e "${BLUE}Stopping all services...${NC}"
        docker-compose stop
        echo -e "${GREEN}✓ All services stopped${NC}"
        ;;
    clean)
        echo -e "${BLUE}Cleaning Docker resources...${NC}"
        docker-compose down -v
        docker system prune -f
        echo -e "${GREEN}✓ Cleanup complete${NC}"
        ;;
    build)
        echo -e "${BLUE}Building Docker image...${NC}"
        docker-compose build
        echo -e "${GREEN}✓ Build complete${NC}"
        ;;
    *)
        echo "Usage: ./docker-test.sh {test|analyze|shell|all|grist-*|start-all|stop-all|clean|build}"
        echo ""
        echo "Flutter Commands:"
        echo "  test         - Run unit tests"
        echo "  analyze      - Run code analysis"
        echo "  shell        - Open interactive bash shell"
        echo "  all          - Run analyze + test"
        echo "  build        - Build Docker image"
        echo ""
        echo "Grist Commands:"
        echo "  grist-start  - Start Grist server"
        echo "  grist-stop   - Stop Grist server"
        echo "  grist-logs   - Show Grist logs"
        echo "  grist-restart- Restart Grist server"
        echo ""
        echo "System Commands:"
        echo "  start-all    - Start all services (Grist + Flutter)"
        echo "  stop-all     - Stop all services"
        echo "  clean        - Remove Docker containers and volumes"
        echo ""
        echo "Examples:"
        echo "  ./docker-test.sh grist-start   # Start Grist"
        echo "  ./docker-test.sh test          # Run tests"
        echo "  ./docker-test.sh all           # Run full suite"
        echo "  ./docker-test.sh start-all     # Start everything"
        exit 1
        ;;
esac
