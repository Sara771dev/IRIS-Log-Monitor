<template>
  <div class="container">
    <div class="top-section">
      <div class="header">
        <img src="../src/assets/process.png" alt="" class="status-icon" />
        <div class="header-text">Console errors and alarms</div>
      </div>
      <div class="status-block">
        <div class="status-item">
          <img src="../src/assets/error.png" alt="" class="status-icon" />
          <div class="status-text">{{ error }}</div>
        </div>
        <div class="status-item">
          <img src="../src/assets/warn.png" alt="" class="status-icon" />
          <div class="status-text">{{ warn }}</div>
        </div>
      </div>
      <el-table :data="tableData" class="table" max-height="280">
        <el-table-column
          prop="TimeAndPid"
          label="Time (Process ID PID)"
        ></el-table-column>
        <el-table-column
          prop="Type"
          label="alarm level"
          width="180"
        ></el-table-column>
        <el-table-column prop="Info" label="details"></el-table-column>
      </el-table>
    </div>

    <div class="row-section">
      <div class="section-item">
        <div class="header">
          <img src="../src/assets/process.png" alt="" class="status-icon" />
          <div class="header-text">Upcoming tasks</div>
        </div>
        <el-table :data="tableData1" class="table" max-height="300">
          <el-table-column prop="Name" label="service name"></el-table-column>
          <el-table-column
            prop="time"
            label="execution time"
            width="180"
          ></el-table-column>
          <el-table-column prop="Status" label="state"></el-table-column>
        </el-table>
      </div>

      <div class="section-item">
        <div class="header">
          <img src="../src/assets/process.png" alt="" class="status-icon" />
          <div class="header-text">Top 5 Process Activity Levels</div>
        </div>
        <el-table :data="tableData2" class="table" max-height="300">
          <el-table-column prop="NameSpace" label="Namespace"></el-table-column>
          <el-table-column
            prop="pID"
            label="Process ID"
            width="180"
          ></el-table-column>
          <el-table-column
            prop="CommandsExecuted"
            label="Command frequency"
          ></el-table-column>
        </el-table>
      </div>
    </div>
    <div class="top-section">
      <div class="header">
        <img src="../src/assets/process.png" alt="" class="status-icon" />
        <div class="header-text">Event log</div>
      </div>
      <div>
        <el-select v-model="value" placeholder="Please select an event" @change="select">
          <el-option
            v-for="item in options"
            :key="item.value"
            :label="item.label"
            :value="item.value"
          >
          </el-option>
        </el-select>
      </div>
      <el-table :data="tableData3" class="table" max-height="300">
        <el-table-column prop="Job" label="Job"></el-table-column>
        <el-table-column
          prop="Method"
          label="Method"
          width="180"
        ></el-table-column>
        <el-table-column prop="Text" label="Text"></el-table-column>
        <el-table-column prop="TimeLogged" label="TimeLogged"></el-table-column>
        <el-table-column prop="Type" label="Type"></el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script>
import axios from "axios";
export default {
  data() {
    return {
      tableData: [],
      error: "",
      warn: "",
      tableData1: [],
      tableData2: [],
      tableData3: [],
      options: [
        {
          value: "2",
          label: "Error",
        },
        {
          value: "3",
          label: "Warning",
        },
        {
          value: "4",
          label: "Info",
        },
      ],
      value: "",
    };
  },
  mounted() {
    axios.post("/LogMonitor/Monitor/Log").then((res) => {
      this.tableData = res.data.Info;
      this.error = res.data.ErrorNum;
      this.warn = res.data.AlertNum;
    });
    axios.post("/LogMonitor/Monitor/Task").then((res) => {
      this.tableData1 = res.data;
    });
    axios.post("/LogMonitor/Monitor/Process").then((res) => {
      this.tableData2 = res.data.ProcessArray;
    });
    axios.post("/LogMonitor/Monitor/LogList", {}).then((res) => {
      this.tableData3 = res.data;
      this.tableData3.forEach((item) => {
        if (item.Type === 2) {
          item.Type = "Error";
        } else if (item.Type === 3) {
          item.Type = "Warning";
        } else if (item.Type === 4) {
          item.Type = "Info";
        }
      });
    });
  },
  methods: {
    select(e) {
      axios.post("/LogMonitor/Monitor/LogList", { type: e }).then((res) => {
        this.tableData3 = res.data;
        this.tableData3.forEach((item) => {
          if (item.Type === 2) {
            item.Type = "Error";
          } else if (item.Type === 3) {
            item.Type = "Warning";
          } else if (item.Type === 4) {
            item.Type = "Info";
          }
        });
      });
    },
  },
};
</script>

<style scoped>
.container {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.top-section {
  background-color: #f9f9f9;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.row-section {
  display: flex;
  justify-content: space-between;
  gap: 20px;
}

.section-item {
  flex: 1;
  background-color: #f9f9f9;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.status-block {
  display: flex;
  justify-content: end;
  margin-bottom: 20px;
}

.status-item {
  display: flex;
  align-items: center;
  margin-right: 20px;
}

.status-icon {
  width: 30px;
  height: 30px;
}

.status-text {
  font-size: 20px;
  margin-left: 10px;
}

.table {
  width: 100%;
  margin-top: 20px;
}

.header {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.header-text {
  font-size: 20px;
  margin-left: 10px;
}
</style>
