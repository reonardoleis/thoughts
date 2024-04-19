import { Route, BrowserRouter as Router, Routes } from "react-router-dom";
import Home from "./pages/Home";
import Post from "./pages/Post";

function App() {
  return (
    <div className="w-screen h-screen bg-slate-900">
      <Router>
        <Routes>
          <Route path="/post/:id" element={<Post />} />
          <Route path="/" element={<Home />} />
        </Routes>
      </Router>
    </div>
  );
}

export default App;
